view: user_summary_pdt {
  derived_table: {
    datagroup_trigger: daily_etl_datagroup
    partition_keys: ["last_order_date"]
    cluster_keys: ["user_id"]

    sql:
      SELECT
        user_id,
        COUNT(id) AS total_items_purchased,
        SUM(sale_price) AS total_spent,
        DATE(MAX(created_at)) AS last_order_date
      FROM `order_items`
      WHERE status = 'Complete'
      GROUP BY 1 ;;
  }

  # --- MAKE SURE USER_ID IS ACCESSIBLE FOR JOINS ---
  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
    # DO NOT include `hidden: yes` while debugging join issues
  }

  dimension_group: last_order {
    type: time
    timeframes: [date, week, month, year]
    datatype: date
    sql: ${TABLE}.last_order_date ;;
  }

  # ... measures ...
}
