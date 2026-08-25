include: "/views/order_items.view.lkml"

view: +order_items {

  # 1. SINGLE GLOBAL DATE FILTER
  filter: selected_date {
    type: date
    description: "Single Global Date Filter for Dashboard, NDT, and PoP Analysis"
  }

  dimension: month_name {
    type: string
    sql: FORMAT_DATE('%b', ${created_raw}) ;;
    order_by_field: month_num
  }

  dimension: month_num {
    type: number
    sql: EXTRACT(MONTH FROM ${created_raw}) ;;
    hidden: yes
  }

  # 2. POP COMPARISON PARAMETER
  parameter: compare_to {
    type: unquoted
    default_value: "previous_period"

    allowed_value: {
      label: "Previous Period"
      value: "previous_period"
    }
    allowed_value: {
      label: "Same Period Last Year"
      value: "prior_year"
    }
  }

  # 3. DYNAMIC PERIOD BUCKETING
  dimension: pop_period {
    type: string
    sql:
      CASE
        {% if selected_date._is_filtered %}
          -- CURRENT PERIOD
          WHEN ${created_raw} >= {% date_start selected_date %}
           AND ${created_raw} <  {% date_end selected_date %}
          THEN 'Current Period'

      -- PREVIOUS PERIOD MODE
      WHEN '{% parameter compare_to %}' = 'previous_period'
      AND ${created_raw} >= TIMESTAMP_SUB({% date_start selected_date %}, INTERVAL DATE_DIFF(DATE({% date_end selected_date %}), DATE({% date_start selected_date %}), DAY) DAY)
      AND ${created_raw} <  {% date_start selected_date %}
      THEN 'Comparison Period'

      -- PRIOR YEAR MODE
      WHEN '{% parameter compare_to %}' = 'prior_year'
      AND ${created_raw} >= TIMESTAMP_SUB({% date_start selected_date %}, INTERVAL 1 YEAR)
      AND ${created_raw} <  TIMESTAMP_SUB({% date_end selected_date %}, INTERVAL 1 YEAR)
      THEN 'Comparison Period'
      {% else %}
      WHEN 1=1 THEN 'Current Period'
      {% endif %}
      ELSE 'Outside Period'
      END ;;
  }

  # 4. BASE MEASURES
  measure: dynamic_ytd_sales {
    hidden: yes
    type: number
    sql: SUM(
      CASE
        {% if selected_date._is_filtered %}
          WHEN ${created_raw} >= TIMESTAMP(DATE_TRUNC(DATE({% date_start selected_date %}), YEAR))
           AND ${created_raw} <= {% date_end selected_date %}
          THEN ${sale_price}
        {% else %}
          WHEN 1=1 THEN ${sale_price}
        {% endif %}
      END
    ) ;;
    value_format_name: usd
  }

  measure: dynamic_ytd_count {
    hidden: yes
    type: number
    sql: COUNT(
      CASE
        {% if selected_date._is_filtered %}
          WHEN ${created_raw} >= TIMESTAMP(DATE_TRUNC(DATE({% date_start selected_date %}), YEAR))
           AND ${created_raw} <= {% date_end selected_date %}
          THEN ${id}
        {% else %}
          WHEN 1=1 THEN ${id}
        {% endif %}
      END
    ) ;;
    value_format_name: decimal_0
  }

  # 5. METRIC SWITCHER PARAMETER
  parameter: brand_rank_measure_selection {
    description: "Global Metric Switcher for Dashboard Tiles & NDT Ranking"
    type: unquoted
    default_value: "order_items_sales_price"

    allowed_value: {
      label: "Order Items Total Sales"
      value: "order_items_sales_price"
    }
    allowed_value: {
      label: "Order Items Count"
      value: "order_items_count"
    }
  }

  # 6. SINGLE DYNAMIC MEASURE
  measure: dynamic_measure {
    label_from_parameter: brand_rank_measure_selection
    type: number
    sql:
      {% assign selected_metric = brand_rank_measure_selection._parameter_value | string %}
      {% if selected_metric contains 'order_items_count' %}
        ${dynamic_ytd_count}
      {% else %}
        ${dynamic_ytd_sales}
      {% endif %} ;;

    html:
      {% assign selected_metric = brand_rank_measure_selection._parameter_value | string %}
      {% if selected_metric contains 'order_items_count' %}
        {{ dynamic_ytd_count._rendered_value }}
      {% else %}
        {{ dynamic_ytd_sales._rendered_value }}
      {% endif %} ;;
  }

  # 7. POP METRICS
  measure: current_period_sales {
    type: sum
    sql: ${sale_price} ;;
    filters: [pop_period: "Current Period"]
    value_format_name: usd
  }

  measure: comparison_period_sales {
    type: sum
    sql: ${sale_price} ;;
    filters: [pop_period: "Comparison Period"]
    value_format_name: usd
  }

  measure: sales_pop_change {
    type: number
    sql: SAFE_DIVIDE(${current_period_sales} - ${comparison_period_sales}, ${comparison_period_sales}) ;;
    value_format_name: percent_2
    html:
      {% if value > 0 %}
        <span style="color: #26B050; font-weight: bold;">▲ {{ rendered_value }}</span>
      {% elsif value < 0 %}
        <span style="color: #DE3618; font-weight: bold;">▼ {{ rendered_value }}</span>
      {% else %}
        <span>{{ rendered_value }}</span>
      {% endif %} ;;
  }

  # 8. MTD SALES (Drill opens Brand, Item Name, ID, and full MTD stats)
  measure: mtd_sales {
    type: number
    sql: SUM(
      CASE
        {% if selected_date._is_filtered %}
          WHEN ${created_raw} >= TIMESTAMP(DATE_TRUNC(DATE({% date_end selected_date %}), MONTH))
           AND ${created_raw} <= {% date_end selected_date %}
          THEN ${sale_price}
        {% else %}
          WHEN ${created_raw} >= TIMESTAMP(DATE_TRUNC(CURRENT_DATE(), MONTH))
          THEN ${sale_price}
        {% endif %}
      END
    ) ;;
    value_format_name: usd
    drill_fields: [
      products.brand,
      products.name,
      id,
      mtd_sales,
      prior_mtd_sales,
      mtd_sales_pop_change
    ]
  }

  # 9. PRIOR MTD SALES
  measure: prior_mtd_sales {
    type: number
    sql: SUM(
      CASE
        {% if selected_date._is_filtered %}
          WHEN ${created_raw} >= TIMESTAMP(DATE_SUB(DATE_TRUNC(DATE({% date_end selected_date %}), MONTH), INTERVAL 1 MONTH))
           AND ${created_raw} <= TIMESTAMP(DATE_SUB(DATE({% date_end selected_date %}), INTERVAL 1 MONTH))
          THEN ${sale_price}
        {% else %}
          WHEN ${created_raw} >= TIMESTAMP(DATE_SUB(DATE_TRUNC(CURRENT_DATE(), MONTH), INTERVAL 1 MONTH))
           AND ${created_raw} <= TIMESTAMP(DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH))
          THEN ${sale_price}
        {% endif %}
      END
    ) ;;
    value_format_name: usd
    drill_fields: [
      products.brand,
      products.name,
      id,
      mtd_sales,
      prior_mtd_sales,
      mtd_sales_pop_change
    ]
  }

  # 10. MTD % CHANGE
  measure: mtd_sales_pop_change {
    type: number
    sql: SAFE_DIVIDE(${mtd_sales} - ${prior_mtd_sales}, ${prior_mtd_sales}) ;;
    value_format_name: percent_2
    html:
      {% if value > 0 %}
        <span style="color: #26B050; font-weight: bold;">▲ {{ rendered_value }}</span>
      {% elsif value < 0 %}
        <span style="color: #DE3618; font-weight: bold;">▼ {{ rendered_value }}</span>
      {% else %}
        <span>{{ rendered_value }}</span>
      {% endif %} ;;
  }
}
