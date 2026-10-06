view: store {
  derived_table: {
    sql:
      SELECT 1 AS store_id, 'Downtown Hub' AS store_name
    ;;
  }

  dimension: store_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.store_id ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.store_name ;;
  }
}
