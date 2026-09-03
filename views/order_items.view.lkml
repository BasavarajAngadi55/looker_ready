view: order_items {
  sql_table_name: `order_items` ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  # Foreign keys used for JOINing tables (hidden to clean up UI)
  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: sale_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;; # e.g. 'Complete', 'Processing', 'Returned'
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  # Measure: Aggregates data (SQL COUNT)
  measure: count {
    type: count
    # drill_fields defines what detailed table pops up when a user clicks this count on a dashboard
    drill_fields: [id, order_id, users.name, products.name, sale_price]
  }

  # Measure: Sums up sale_price
  measure: total_revenue {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }
}
