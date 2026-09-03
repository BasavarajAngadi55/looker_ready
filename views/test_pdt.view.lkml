view: user_summary_pdt_1 {
  derived_table: {
    sql:
    SELECT
    user_id,
    COUNT(id) AS total_items_purchased,
    SUM(sale_price) AS total_spent,
    DATE(MAX(created_at)) AS last_order_date
    FROM `order_items`
    WHERE status = 'Shipped'
    GROUP BY 1 ;;

    # Rebuilds using a datagroup (or use persist_for: "24 hours" for testing)
    datagroup_trigger: daily_etl_datagroup
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  measure: total_spent {
    type: sum
    sql: ${TABLE}.total_spent ;;
  }
}
