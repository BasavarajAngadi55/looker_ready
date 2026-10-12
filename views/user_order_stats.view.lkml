view: user_order_stats {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: order_count { field: order_items.count }
      column: total_revenue { field: order_items.total_revenue }

      # BIND FILTER: Passes the order_items date filter into the derived table CTE
      bind_filters: {
        to_field: order_items.created_date
        from_field: order_items.created_date
      }
    }
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_count {
    type: number
    sql: ${TABLE}.order_count ;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}.total_revenue ;;
  }
}
