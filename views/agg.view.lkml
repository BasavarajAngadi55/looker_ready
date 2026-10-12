view: product_order_summary {
  derived_table: {
    explore_source: order_items {
      column: product_id { field: order_items.product_id }
      column: sale_price { field: order_items.sale_price }

    }
    # Optional: Set up datagroup for automatic caching & aggregate awareness materialization
    # datagroup_trigger: daily_etl_datagroup
  }

  # --- Dimensions ---
  dimension: product_id {
    primary_key: yes
    type: number
    hidden: no
    sql: ${TABLE}.product_id ;;
  }

  # --- Measures derived from the NDT ---
  measure: total_revenue {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.sale_price ;;
  }


}
