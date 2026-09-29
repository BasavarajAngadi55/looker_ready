# Connection name configured in your Looker Admin settings
connection: "looker_partner_demo"

# LookML Includes (All includes grouped at the top)
include: "/views/**/*.view.lkml"
include: "/views/check.view.lkml"
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
}

# Simple explore definition referencing test_dev_mode view
explore: check {
  label: "Dev/Prod Test Explore"
}
