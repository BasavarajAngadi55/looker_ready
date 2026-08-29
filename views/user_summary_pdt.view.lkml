view: user_summary_pdt {
  derived_table: {
    # Custom SQL aggregation query
    sql:
      SELECT
        user_id,
        COUNT(id) AS total_items_purchased,
        SUM(sale_price) AS total_spent,
        MAX(created_at) AS last_order_date
      FROM `my_project.my_dataset.order_items`
      WHERE status = 'Complete'
      GROUP BY 1 ;;

    # Datagroup Trigger: Rebuilds this table in the DB only when the datagroup checks for new data
    datagroup_trigger: ecommerce_etl_datagroup

    # BigQuery/Snowflake physical optimization keys
    cluster_keys: ["user_id"]
    partition_keys: ["last_order_date"]
  }

  dimension: user_id {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: total_spent {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_spent ;;
  }

  # Creates customer segments for dashboard filtering
  dimension: user_tier {
    type: string
    sql:
      CASE
        WHEN ${total_spent} > 1000 THEN 'VIP ($1000+)'
        WHEN ${total_spent} BETWEEN 200 AND 1000 THEN 'Regular ($200-$1000)'
        ELSE 'Low Value (<$200)'
      END ;;
  }
}
