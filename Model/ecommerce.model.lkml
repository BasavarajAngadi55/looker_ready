# Connection name configured in your Looker Admin settings
connection: "looker_partner_demo"

# Includes all view files from subdirectoriess
include: "/views/**/*.view.lkml"

# Inside your .model.lkml file:
include: "/Dashboard/*.dashboard.lookml"  # or include: "*.dashboard"

datagroup: daily_etl_datagroup {
  # 1. Looker runs this query periodically to check for changes
  sql_trigger: SELECT MAX(id) FROM demo_db.orders ;;

  # 2. Maximum time cache/PDT stays valid if the trigger hasn't changed
  max_cache_age: "24 hours"
}
# Tells all explores in this model to use this datagroup by default
persist_with: daily_etl_datagroup

# EXPLORE: Defines how views are joined together for reporting and dashboard tiles
explore: order_items {
  label: "Executive Ecommerce Analysis"

  # Explicitly applying datagroup to this explore
  persist_with: daily_etl_datagroup

  # JOIN 1: Users View
  join: users {
    type: left_outer
    relationship: many_to_one # Many order items belong to 1 user
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  # JOIN 2: Products View
  join: products {
    type: left_outer
    relationship: many_to_one # Many order items belong to 1 product
    sql_on: ${order_items.product_id} = ${products.id} ;;
  }

  # JOIN 3: Persistent Derived Table (PDT)
  join: user_summary_pdt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${user_summary_pdt.user_id} ;;
  }

  # JOIN 4: Native Derived Table (NDT)
  join: user_metrics_ndt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${user_metrics_ndt.user_id} ;;
  }


    join: user_summary_pdt_1 {
      type: left_outer
      relationship: one_to_one
      sql_on: ${users.id} = ${user_summary_pdt_1.user_id} ;;
    }
  }
