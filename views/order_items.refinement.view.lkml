include: "/views/order_items.view.lkml"

# The '+' sign overlays this logic onto the order_items view
view: +order_items {

  # 1. Custom Categorization Dimension
  dimension: price_tier {
    type: string
    sql:
      CASE
        WHEN ${sale_price} < 20 THEN '1. Low (< $20)'
        WHEN ${sale_price} BETWEEN 20 AND 100 THEN '2. Medium ($20 - $100)'
        ELSE '3. High (> $100)'
      END ;;
  }

  # 2. Time Transformation (Days Ago Calculation for Period-over-Period)
  dimension: days_since_created {
    type: number
    sql: TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY) ;;
  }

  dimension: period_selected {
    type: string
    sql:
      CASE
        WHEN ${days_since_created} <= 30 THEN 'Current Period (Last 30 Days)'
        WHEN ${days_since_created} BETWEEN 31 AND 60 THEN 'Prior Period (31-60 Days Ago)'
        ELSE 'Historical'
      END ;;
  }

  # 3. Filtered Measure: Sums sale_price ONLY when status is 'Returned'
  measure: returned_revenue {
    type: sum
    sql: ${sale_price} ;;
    filters: [status: "Returned"]
    value_format_name: usd
  }

  measure: current_period_revenue {
    type: sum
    sql: ${sale_price} ;;
    filters: [period_selected: "Current Period (Last 30 Days)"]
    value_format_name: usd
  }

  measure: prior_period_revenue {
    type: sum
    sql: ${sale_price} ;;
    filters: [period_selected: "Prior Period (31-60 Days Ago)"]
    value_format_name: usd
  }

  # 4. Computed Ratio Measure with Conditional Alert Formatting
  measure: return_rate {
    type: number
    sql: 1.0 * ${returned_revenue} / NULLIF(${total_revenue}, 0) ;;
    value_format_name: percent_2
    html:
      {% if value > 0.15 %}
        <span style="color: #d32f2f; font-weight: bold; background-color: #ffebee; padding: 2px 4px; border-radius: 3px;">{{ rendered_value }} ⚠️</span>
      {% else %}
        <span style="color: #2e7d32;">{{ rendered_value }}</span>
      {% endif %} ;;
  }

  # 5. Period-Over-Period Growth Formula
  measure: pop_revenue_growth {
    type: number
    sql: (${current_period_revenue} - ${prior_period_revenue}) / NULLIF(${prior_period_revenue}, 0) ;;
    value_format_name: percent_2
  }
}
