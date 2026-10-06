view: fact_category_targets {
  derived_table: {
    sql:
      SELECT 'T-CAT-1' AS target_id, 1 AS store_id, 1 AS category_id, 15000.00 AS target_amount
      UNION ALL
      SELECT 'T-CAT-2', 1, 2, 2000.00
    ;;
  }

  dimension: target_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.target_id ;;
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

  measure: total_category_target {
    type: sum
    sql: ${TABLE}.target_amount ;;
    value_format_name: usd
  }
}
