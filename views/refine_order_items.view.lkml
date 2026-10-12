include: "/views/**/*.view.lkml"

view: +order_items {

  # -------------------------------------------------------------
  # 1. SINGLE GLOBAL ANCHOR FILTER
  # -------------------------------------------------------------
  filter: created_date_filter {
    type: date
    label: "Created Date Filter (Global)"
    description: "Primary dashboard filter that controls all current, rolling, YTD Evolution, and PY timeframes."
  }

  # -------------------------------------------------------------
  # 2. TARGET DATE & ANCHORS (CURRENT PERIODS)
  # -------------------------------------------------------------

  # Captured selected date (defaults to today if unfiltered)
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

  # Extract Day and Year for YTD Evolution logic
  dimension: selected_day_of_month {
    type: number
    hidden: yes
    sql: EXTRACT(DAY FROM ${selected_target_date}) ;;
  }

  dimension: selected_year {
    type: number
    hidden: yes
    sql: EXTRACT(YEAR FROM ${selected_target_date}) ;;
  }

  # Previous Day
  dimension: previous_day_date {
    type: date
    hidden: yes
    sql: DATE_SUB(${selected_target_date}, INTERVAL 1 DAY) ;;
  }

  # Rolling 7 Days Start Date (Target Date - 6 Days)
  dimension: start_of_r7d {
    type: date
    hidden: yes
    sql: DATE_SUB(${selected_target_date}, INTERVAL 6 DAY) ;;
  }

  # Current Week Start (Monday)
  dimension: start_of_wtd_week {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${selected_target_date}, WEEK(MONDAY)) ;;
  }

  # Current Month Start (1st of the Month)
  dimension: start_of_mtd_month {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${selected_target_date}, MONTH) ;;
  }

  # Current Quarter Start (1st of the Quarter)
  dimension: start_of_qtd_quarter {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${selected_target_date}, QUARTER) ;;
  }

  # Current Year Start (Jan 1st)
  dimension: start_of_ytd_year {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${selected_target_date}, YEAR) ;;
  }

  # -------------------------------------------------------------
  # 3. ANCHORS (PREVIOUS YEAR PERIODS)
  # -------------------------------------------------------------

  # PY Target Date (1 year prior to selected target date)
  dimension: py_same_calendar_date {
    type: date
    hidden: yes
    sql: DATE_SUB(${selected_target_date}, INTERVAL 1 YEAR) ;;
  }

  # PY Rolling 7 Days Start Date (PY Target Date - 6 Days)
  dimension: start_of_py_r7d {
    type: date
    hidden: yes
    sql: DATE_SUB(${py_same_calendar_date}, INTERVAL 6 DAY) ;;
  }

  # PY WTD Start (Monday of that week 1 year ago)
  dimension: start_of_py_calendar_wtd_week {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${py_same_calendar_date}, WEEK(MONDAY)) ;;
  }

  # PY MTD Start (1st of that month 1 year ago)
  dimension: start_of_py_mtd_month {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${py_same_calendar_date}, MONTH) ;;
  }

  # PY QTD Start (1st of that quarter 1 year ago)
  dimension: start_of_py_qtd_quarter {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${py_same_calendar_date}, QUARTER) ;;
  }

  # PY YTD Start (Jan 1st 1 year ago)
  dimension: start_of_py_ytd_year {
    type: date
    hidden: yes
    sql: DATE_TRUNC(${py_same_calendar_date}, YEAR) ;;
  }

  # -------------------------------------------------------------
  # 4. EVALUATION FLAGS
  # -------------------------------------------------------------

  # --- Current Period Flags ---
  dimension: is_selected_date {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) = ${selected_target_date} ;;
  }

  dimension: is_previous_day {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) = ${previous_day_date} ;;
  }

  dimension: is_r7d_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_r7d}
      AND DATE(${TABLE}.created_at) <= ${selected_target_date} ;;
  }

  dimension: is_wtd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_wtd_week}
      AND DATE(${TABLE}.created_at) <= ${selected_target_date} ;;
  }

  dimension: is_mtd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_mtd_month}
      AND DATE(${TABLE}.created_at) <= ${selected_target_date} ;;
  }

  dimension: is_qtd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_qtd_quarter}
      AND DATE(${TABLE}.created_at) <= ${selected_target_date} ;;
  }

  dimension: is_ytd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_ytd_year}
      AND DATE(${TABLE}.created_at) <= ${selected_target_date} ;;
  }

  # --- YTD Evolution Flag ---
  dimension: is_ytd_evolution_day {
    type: yesno
    hidden: yes
    description: "Evaluates True for any date in the selected year whose day-of-month is <= selected target day."
    sql: EXTRACT(YEAR FROM ${TABLE}.created_at) = ${selected_year}
           AND DATE(${TABLE}.created_at) <= ${selected_target_date}
           AND EXTRACT(DAY FROM ${TABLE}.created_at) <= ${selected_day_of_month} ;;
  }

  # --- Previous Year Flags ---
  dimension: is_py_selected_date {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) = ${py_same_calendar_date} ;;
  }

  dimension: is_py_r7d_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_py_r7d}
      AND DATE(${TABLE}.created_at) <= ${py_same_calendar_date} ;;
  }

  dimension: is_py_wtd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_py_calendar_wtd_week}
      AND DATE(${TABLE}.created_at) <= ${py_same_calendar_date} ;;
  }

  dimension: is_py_mtd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_py_mtd_month}
      AND DATE(${TABLE}.created_at) <= ${py_same_calendar_date} ;;
  }

  dimension: is_py_qtd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_py_qtd_quarter}
      AND DATE(${TABLE}.created_at) <= ${py_same_calendar_date} ;;
  }

  dimension: is_py_ytd_window {
    type: yesno
    hidden: yes
    sql: DATE(${TABLE}.created_at) >= ${start_of_py_ytd_year}
      AND DATE(${TABLE}.created_at) <= ${py_same_calendar_date} ;;
  }

  # -------------------------------------------------------------
  # 5. MEASURES
  # -------------------------------------------------------------

  # --- Daily Measures ---
  measure: sales_selected_date {
    type: sum
    label: "Sales (Selected Date)"
    value_format_name: usd
    sql: CASE WHEN ${is_selected_date} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_previous_day {
    type: sum
    label: "Sales (Previous Day)"
    value_format_name: usd
    sql: CASE WHEN ${is_previous_day} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_py_selected_date {
    type: sum
    label: "Sales (PY Selected Date)"
    value_format_name: usd
    sql: CASE WHEN ${is_py_selected_date} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  # --- Rolling Measures ---
  measure: sales_rolling_7d {
    type: sum
    label: "Sales (Rolling 7 Days)"
    description: "Calculates total sales for the 7-day window ending on the selected target date."
    value_format_name: usd
    sql: CASE WHEN ${is_r7d_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_py_rolling_7d {
    type: sum
    label: "Sales (PY Rolling 7 Days)"
    description: "Calculates total sales for the 7-day window ending on the same calendar date last year."
    value_format_name: usd
    sql: CASE WHEN ${is_py_r7d_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  # --- Current Period Measures ---
  measure: sales_wtd {
    type: sum
    label: "Sales (WTD)"
    value_format_name: usd
    sql: CASE WHEN ${is_wtd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_mtd {
    type: sum
    label: "Sales (MTD)"
    value_format_name: usd
    sql: CASE WHEN ${is_mtd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_qtd {
    type: sum
    label: "Sales (QTD)"
    value_format_name: usd
    sql: CASE WHEN ${is_qtd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_ytd {
    type: sum
    label: "Sales (YTD)"
    value_format_name: usd
    sql: CASE WHEN ${is_ytd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  # --- YTD Evolution Measure ---
  measure: sales_ytd_evolution {
    type: sum
    label: "Sales (YTD Evolution)"
    description: "Calculates sales per month from day 1 up to the selected day of the month."
    value_format_name: usd
    sql: CASE WHEN ${is_ytd_evolution_day} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  # --- Previous Year Period Measures ---
  measure: sales_py_wtd {
    type: sum
    label: "Sales (PY WTD)"
    value_format_name: usd
    sql: CASE WHEN ${is_py_wtd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_py_mtd {
    type: sum
    label: "Sales (PY MTD)"
    value_format_name: usd
    sql: CASE WHEN ${is_py_mtd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_py_qtd {
    type: sum
    label: "Sales (PY QTD)"
    value_format_name: usd
    sql: CASE WHEN ${is_py_qtd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }

  measure: sales_py_ytd {
    type: sum
    label: "Sales (PY YTD)"
    value_format_name: usd
    sql: CASE WHEN ${is_py_ytd_window} THEN ${TABLE}.sale_price ELSE NULL END ;;
  }
}
