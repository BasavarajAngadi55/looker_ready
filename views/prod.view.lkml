view: prod {
  derived_table: {
    sql:
      SELECT 101 AS product_id, 'Laptop' AS product_name
      UNION ALL
      SELECT 102, 'Phone'
      UNION ALL
      SELECT 103, 'Desk Chair'
    ;;
  }

  dimension: product_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }
}
