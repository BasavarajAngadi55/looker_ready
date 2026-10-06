view: cat {
  derived_table: {
    sql:
      SELECT 1 AS category_id, 'Electronics' AS category_name
      UNION ALL
      SELECT 2, 'Furniture'
    ;;
  }

  dimension: category_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.category_id ;;
  }

  dimension: category_name {
    type: string
    sql: ${TABLE}.category_name ;;
  }
}
