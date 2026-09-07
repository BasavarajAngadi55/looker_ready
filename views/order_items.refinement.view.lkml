include: "/views/order_items.view.lkml"

view: +order_items {

  # ===================================================================
  # 1. SINGLE TARGET DATE CONTROLLER FILTER (Template Filter))))))
  # ===================================================================
  filter: target_date {
    label: "PoP: Select Target Date"
    type: date
    description: "User selects a single date (e.g. 2026-09-04) to calculate all PoP & xTD metrics."
  }

  # ===================================================================
  # 2. TYPE-SAFE BIGQUERY MEASURES (Converts Liquid Timestamp to Date)
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

}
