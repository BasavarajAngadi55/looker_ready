view: user_metrics_ndt {
  derived_table: {
    # References the order_items explore logic natively
    explore_source: order_items {
      column: user_id { field: order_items.user_id }
      column: total_revenue { field: order_items.total_revenue }
      column: returned_revenue { field: order_items.returned_revenue }
    }
    datagroup_trigger: ecommerce_etl_datagroup
  }

  dimension: user_id {
    primary_key: yes
    type: number
    hidden: yes
  }

  dimension: total_revenue {
    type: number
    value_format_name: usd
  }
}
