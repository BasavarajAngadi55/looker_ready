include: "/views/**/*.view.lkml"


view: +order_items {

  # ---------------------------------------------------------------------
  # 1. ANCHOR DATE (CASTED TO DATE TYPE FOR BIGQUERY)
  # ---------------------------------------------------------------------
  dimension: filter_anchor_date {
    type: date
    hidden: yes
    sql: {% if created_date._is_filtered %}
           (SELECT DATE(MAX(created_at)) FROM ${order_items.SQL_TABLE_NAME} WHERE {% condition created_date %} created_at {% endcondition %})
         {% else %}
           CURRENT_DATE()
         {% endif %} ;;
  }

  # Helper dimension converting TIMESTAMP column to DATE for clean BigQuery comparisons
  dimension: created_date_only {
    type: date
    hidden: yes
    sql: DATE(${TABLE}.created_at) ;;
  }

  # ---------------------------------------------------------------------
  # 2. RELATIVE TIME FLAGS (EXPLICIT DATE COMPARISONS)
  # ---------------------------------------------------------------------

  # --- TODAY vs YESTERDAY ---
  dimension: is_selected_day {
    type: yesno
    hidden: yes
    sql: ${created_date_only} = ${filter_anchor_date} ;;
  }

  dimension: is_yesterday {
    type: yesno
    hidden: yes
    sql: ${created_date_only} = DATE_SUB(${filter_anchor_date}, INTERVAL 1 DAY) ;;
  }

  # --- WEEK TO DATE (WTD) ---
  dimension: is_wtd {
    type: yesno
    hidden: yes
    sql: ${created_date_only} >= DATE_TRUNC(${filter_anchor_date}, WEEK)
      AND ${created_date_only} <= ${filter_anchor_date} ;;
  }

  dimension: is_prior_wtd {
    type: yesno
    hidden: yes
    sql: ${created_date_only} >= DATE_SUB(DATE_TRUNC(${filter_anchor_date}, WEEK), INTERVAL 1 WEEK)
      AND ${created_date_only} <= DATE_SUB(${filter_anchor_date}, INTERVAL 1 WEEK) ;;
  }

  # --- MONTH TO DATE (MTD) ---
  dimension: is_mtd {
    type: yesno
    hidden: yes
    sql: ${created_date_only} >= DATE_TRUNC(${filter_anchor_date}, MONTH)
      AND ${created_date_only} <= ${filter_anchor_date} ;;
  }

  dimension: is_prior_year_mtd {
    type: yesno
    hidden: yes
    sql: ${created_date_only} >= DATE_SUB(DATE_TRUNC(${filter_anchor_date}, MONTH), INTERVAL 1 YEAR)
      AND ${created_date_only} <= DATE_SUB(${filter_anchor_date}, INTERVAL 1 YEAR) ;;
  }

  # --- QUARTER TO DATE (QTD) ---
  dimension: is_qtd {
    type: yesno
    hidden: yes
    sql: ${created_date_only} >= DATE_TRUNC(${filter_anchor_date}, QUARTER)
      AND ${created_date_only} <= ${filter_anchor_date} ;;
  }

  dimension: is_prior_year_qtd {
    type: yesno
    hidden: yes
    sql: ${created_date_only} >= DATE_SUB(DATE_TRUNC(${filter_anchor_date}, QUARTER), INTERVAL 1 YEAR)
      AND ${created_date_only} <= DATE_SUB(${filter_anchor_date}, INTERVAL 1 YEAR) ;;
  }

  # --- YEAR TO DATE (YTD) ---
  dimension: is_ytd {
    type: yesno
    hidden: yes
    sql: ${created_date_only} >= DATE_TRUNC(${filter_anchor_date}, YEAR)
      AND ${created_date_only} <= ${filter_anchor_date} ;;
  }

  dimension: is_prior_year_ytd {
    type: yesno
    hidden: yes
    sql: ${created_date_only} >= DATE_SUB(DATE_TRUNC(${filter_anchor_date}, YEAR), INTERVAL 1 YEAR)
      AND ${created_date_only} <= DATE_SUB(${filter_anchor_date}, INTERVAL 1 YEAR) ;;
  }

  # ---------------------------------------------------------------------
  # 3. KPI MEASURES
  # ---------------------------------------------------------------------

  # Today vs Yesterday
  measure: sales_today {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_selected_day: "yes"]
    value_format_name: usd
    label: "Sales (Selected Day)"
  }

  measure: sales_yesterday {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_yesterday: "yes"]
    value_format_name: usd
    label: "Sales (Yesterday)"
  }

  measure: sales_dod_change {
    type: number
    sql: (${sales_today} - ${sales_yesterday}) / NULLIF(${sales_yesterday}, 0) ;;
    value_format_name: percent_1
    label: "Sales DoD % Change"
  }

  # WTD
  measure: sales_wtd {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_wtd: "yes"]
    value_format_name: usd
    label: "Sales (WTD)"
  }

  measure: sales_prior_wtd {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_prior_wtd: "yes"]
    value_format_name: usd
    label: "Sales (Prior WTD)"
  }

  measure: sales_wtd_change {
    type: number
    sql: (${sales_wtd} - ${sales_prior_wtd}) / NULLIF(${sales_prior_wtd}, 0) ;;
    value_format_name: percent_1
    label: "Sales WTD % Change"
  }

  # MTD
  measure: sales_mtd {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_mtd: "yes"]
    value_format_name: usd
    label: "Sales (MTD)"
  }

  measure: sales_prior_mtd {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_prior_year_mtd: "yes"]
    value_format_name: usd
    label: "Sales (Prior Year MTD)"
  }

  measure: sales_mtd_change {
    type: number
    sql: (${sales_mtd} - ${sales_prior_mtd}) / NULLIF(${sales_prior_mtd}, 0) ;;
    value_format_name: percent_1
    label: "Sales MTD % Change (YoY)"
  }

  # QTD
  measure: sales_qtd {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_qtd: "yes"]
    value_format_name: usd
    label: "Sales (QTD)"
  }

  measure: sales_prior_qtd {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_prior_year_qtd: "yes"]
    value_format_name: usd
    label: "Sales (Prior Year QTD)"
  }

  measure: sales_qtd_change {
    type: number
    sql: (${sales_qtd} - ${sales_prior_qtd}) / NULLIF(${sales_prior_qtd}, 0) ;;
    value_format_name: percent_1
    label: "Sales QTD % Change (YoY)"
  }

  # YTD
  measure: sales_ytd {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_ytd: "yes"]
    value_format_name: usd
    label: "Sales (YTD)"
  }

  measure: sales_prior_ytd {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_prior_year_ytd: "yes"]
    value_format_name: usd
    label: "Sales (Prior Year YTD)"
  }

  measure: sales_ytd_change {
    type: number
    sql: (${sales_ytd} - ${sales_prior_ytd}) / NULLIF(${sales_prior_ytd}, 0) ;;
    value_format_name: percent_1
    label: "Sales YTD % Change (YoY)"
  }

  # Rolling 7 Days
  dimension: is_rolling_7_days {
    type: yesno
    hidden: yes
    sql: ${created_date_only} <= ${filter_anchor_date}
      AND ${created_date_only} > DATE_SUB(${filter_anchor_date}, INTERVAL 7 DAY) ;;
  }

  measure: sales_rolling_7_days {
    type: sum
    sql: ${TABLE}.sale_price ;;
    filters: [is_rolling_7_days: "yes"]
    value_format_name: usd
    label: "Sales (Rolling 7 Days)"
  }
}
