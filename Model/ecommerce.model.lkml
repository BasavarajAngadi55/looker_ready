# Connection name configured in your Looker Admin settings
connection: "looker_partner_demo"

# LookML Includes (All includes grouped at the top)
include: "/views/**/*.view.lkml"
include: "/tests/*.lkml"
include: "/Dashboard/*.dashboard.lookml"

# Fiscal offset configuration
fiscal_month_offset: 1

# Caching & Datagroup Configurations
datagroup: daily_etl_datagroup {
  # 1. Looker runs this query periodically to check for changes
  sql_trigger: SELECT MAX(id) FROM order_items ;;

  # 2. Maximum time cache/PDT stays valid if the trigger hasn't changed
  max_cache_age: "24 hours"
}

# Tells all explores in this model to use this datagroup by default
persist_with: daily_etl_datagroup


# EXPLORE DEFINITIONS

explore: order_items {
  label: "Executive Ecommerce Analysis"
  persist_with: daily_etl_datagroup

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

# Join Product-Level Aggregate Derived Table
  join: product_order_summary {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.product_id} = ${product_order_summary.product_id} ;;
  }

  join: user_order_stats {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${user_order_stats.user_id} ;;
  }

# --- Aggregate Awareness Configuration ---
  aggregate_table: product_daily_summary {
    query: {
      dimensions: [product_id]
      measures: [total_revenue]
    }
    materialization: {
      datagroup_trigger: daily_etl_datagroup
    }
  }

}



explore: fact_sales {
  label: "Sales vs Category Targets"

  # Join Dimensions
  join: store {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_sales.store_id} = ${store.store_id} ;;
  }

  join: cat {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_sales.category_id} = ${cat.category_id} ;;
  }

  join: prod {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_sales.product_id} = ${prod.product_id} ;;
  }

  # Join Target table ONLY on shared keys (Store + Category)
  join: fact_category_targets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_sales.store_id} = ${fact_category_targets.store_id}
      AND ${fact_sales.category_id} = ${fact_category_targets.category_id} ;;
  }


}
