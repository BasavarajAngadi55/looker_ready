include: "/views/order_items.view.lkml"

view: +order_items {

  # ===================================================================
  # 1. SINGLE TARGET DATE CONTROLLER FILTER (Template Filter)
  # ===================================================================
  filter: target_date {
    label: "PoP: Select Target Date"
    type: date
    description: "User selects a single date (e.g. 2026-09-04) to calculate all PoP & xTD metrics."
  }

  # ===================================================================
  # 2. BASE MEASURE (Required by Native PoP)
  # ===================================================================
  measure: total_sale_price {
    label: "Total Sales"
    type: sum
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
  }

  # ===================================================================
  # 3. TYPE-SAFE BIGQUERY MEASURES (Single-Date Scorecard Engine)
  # ===================================================================

  # A. Selected Day Value
  measure: sales_selected_day {
    label: "Sales (Selected Day)"
    type: sum
    sql:
      CASE
        WHEN ${created_date} = DATE({% date_start target_date %})
          THEN ${TABLE}.sale_price
        ELSE NULL
      END ;;
    value_format_name: usd
  }

  # B. Day-over-Day (DoD) Value (1 day prior)
  measure: sales_dod_prior_day {
    label: "Sales (DoD Prior Day)"
    type: sum
    sql:
      CASE
        WHEN ${created_date} = DATE_SUB(DATE({% date_start target_date %}), INTERVAL 1 DAY)
          THEN ${TABLE}.sale_price
        ELSE NULL
      END ;;
    value_format_name: usd
  }

  # C. Week-over-Week (WoW) Value (7 days prior)
  measure: sales_wow_prior_week {
    label: "Sales (WoW Prior Week)"
    type: sum
    sql:
      CASE
        WHEN ${created_date} = DATE_SUB(DATE({% date_start target_date %}), INTERVAL 7 DAY)
          THEN ${TABLE}.sale_price
        ELSE NULL
      END ;;
    value_format_name: usd
  }

  # D. Month-over-Month (MoM) Value (1 month prior)
  measure: sales_mom_prior_month {
    label: "Sales (MoM Prior Month)"
    type: sum
    sql:
      CASE
        WHEN ${created_date} = DATE_SUB(DATE({% date_start target_date %}), INTERVAL 1 MONTH)
          THEN ${TABLE}.sale_price
        ELSE NULL
      END ;;
    value_format_name: usd
  }

  # E. Year-over-Year (YoY) Value (1 year prior)
  measure: sales_yoy_prior_year {
    label: "Sales (YoY Prior Year)"
    type: sum
    sql:
      CASE
        WHEN ${created_date} = DATE_SUB(DATE({% date_start target_date %}), INTERVAL 1 YEAR)
          THEN ${TABLE}.sale_price
        ELSE NULL
      END ;;
    value_format_name: usd
  }

  # F. Month-to-Date (MTD) Sales
  measure: sales_mtd {
    label: "Sales (MTD)"
    type: sum
    sql:
      CASE
        WHEN ${created_date} >= DATE_TRUNC(DATE({% date_start target_date %}), MONTH)
         AND ${created_date} <= DATE({% date_start target_date %})
          THEN ${TABLE}.sale_price
        ELSE NULL
      END ;;
    value_format_name: usd
  }

  # G. Quarter-to-Date (QTD) Sales
  measure: sales_qtd {
    label: "Sales (QTD)"
    type: sum
    sql:
      CASE
        WHEN ${created_date} >= DATE_TRUNC(DATE({% date_start target_date %}), QUARTER)
         AND ${created_date} <= DATE({% date_start target_date %})
          THEN ${TABLE}.sale_price
        ELSE NULL
      END ;;
    value_format_name: usd
  }

  # H. Year-to-Date (YTD) Sales
  measure: sales_ytd {
    label: "Sales (YTD)"
    type: sum
    sql:
      CASE
        WHEN ${created_date} >= DATE_TRUNC(DATE({% date_start target_date %}), YEAR)
         AND ${created_date} <= DATE({% date_start target_date %})
          THEN ${TABLE}.sale_price
        ELSE NULL
      END ;;
    value_format_name: usd
  }

  # ===================================================================
  # 4. NATIVE LOOKER PERIOD-OVER-PERIOD MEASURES
  # ===================================================================

  # A. Year-over-Year (YoY) Prior Period Value
  measure: total_sales_prior_year {
    label: "Total Sales (Prior Year)"
    type: period_over_period
    based_on: total_sale_price
    based_on_time: created_date
    period: year
    kind: previous
    value_format_name: usd
  }

  # B. Year-over-Year (YoY) Percentage Growth
  measure: total_sales_yoy_growth {
    label: "Sales YoY Growth %"
    type: period_over_period
    based_on: total_sale_price
    based_on_time: created_date
    period: year
    kind: relative_change
    value_format_name: percent_2
  }

  # C. Month-over-Month (MoM) Prior Period Value
  measure: total_sales_prior_month {
    label: "Total Sales (Prior Month)"
    type: period_over_period
    based_on: total_sale_price
    based_on_time: created_date
    period: month
    kind: previous
    value_format_name: usd
  }

  # D. Month-over-Month (MoM) Percentage Growth
  measure: total_sales_mom_growth {
    label: "Sales MoM Growth %"
    type: period_over_period
    based_on: total_sale_price
    based_on_time: created_date
    period: month
    kind: relative_change
    value_format_name: percent_2
  }

}
