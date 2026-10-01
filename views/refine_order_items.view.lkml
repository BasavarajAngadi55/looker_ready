include: "/views/**/*.view.lkml"

view: +order_items {

# 1. BASE MEASURE
  measure: total_sale_price {
    type: sum
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd
    label: "Total Sales"
  }

# ---------------------------------------------------------------------
  # 2. NATIVE DAY-OVER-DAY (TODAY VS YESTERDAY)
  # ---------------------------------------------------------------------
  measure: sales_previous_day {
    type: period_over_period
    based_on: total_sale_price
    based_on_time: created_date
    period: date
    kind: previous
    value_format_name: usd
    label: "Sales (Previous Day)"
  }





  }
