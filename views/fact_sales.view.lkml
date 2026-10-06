view: fact_sales {
  derived_table: {
    sql:
      SELECT 1 AS sale_id, 1 AS store_id, 1 AS category_id, 101 AS product_id, 1200.00 AS sales_amount
      UNION ALL
      SELECT 2, 1, 1, 102, 800.00
      UNION ALL
      SELECT 3, 1, 2, 103, 250.00
    ;;
  }

  dimension: sale_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.sale_id ;;
  }

  dimension: store_id {
    type: number
    hidden: yes
    sql: ${TABLE}.store_id ;;
  }

  dimension: category_id {
    type: number
    hidden: yes
    sql: ${TABLE}.category_id ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  measure: total_sales {
    type: sum
    sql: ${TABLE}.sales_amount ;;
    value_format_name: usd
  }
}
