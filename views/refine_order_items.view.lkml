include: "/views/**/*.view.lkml"

view: +order_items {

  # -------------------------------------------------------------
  # 1. GLOBAL FILTER DIMENSION
  # -------------------------------------------------------------
  filter: created_date_filter {
    type: date
    label: "Date Filter (Global)"
    description: "Primary dashboard filter controlling Daily, Selected Period, and WTD measures."
  }

  # -------------------------------------------------------------
  # 2. DYNAMIC DATE LOGIC (LIQUID)
  # -------------------------------------------------------------

  # Max date selected in filter (defaults to today if unfiltered)
  dimension: selected_target_date {
    type: date
    hidden: yes
    sql: {% if created_date_filter._is_filtered %}
           (SELECT MAX(DATE(created_at))
            FROM ${order_items.SQL_TABLE_NAME}
            WHERE {% condition created_date_filter %} created_at {% endcondition %})
         {% else %}
           CURRENT_DATE()
         {% endif %} ;;
  }

  # Monday of the week for the target date
  dimension: start_of_wtd_week {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${selected_target_date}, WEEK(MONDAY)) ;;
  }

  # -------------------------------------------------------------
  # 3. EVALUATION FLAGS
  # -------------------------------------------------------------

  # Flag for the exact range or date picked in the global filter
  dimension: is_in_filter_range {
    type: yesno
    hidden: yes
    sql: {% condition created_date_filter %} ${TABLE}.created_at {% endcondition %} ;;
  }

  # Flag for WTD Window (Monday -> Target Date)
  dimension: is_wtd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_wtd_week}
      AND DATE(${TABLE}.created_at) <= ${selected_target_date} ;;
  }

  # -------------------------------------------------------------
  # 4. MEASURES
  # -------------------------------------------------------------

  # Standard Sales: Responds directly to whatever date/range is picked in created_date_filter
  measure: total_sales {
    type: sum
    label: "Total Sales"
    description: "Calculates total sales for the date or date range selected in the global filter."
    value_format_name: usd
    sql: CASE WHEN ${is_in_filter_range} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  # WTD Sales: Calculates Monday to Selected Target Date
  measure: sales_wtd {
    type: sum
    label: "Sales (WTD)"
    description: "Calculates WTD sales starting from Monday up to the selected date."
    value_format_name: usd
    sql: CASE WHEN ${is_wtd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }
}
