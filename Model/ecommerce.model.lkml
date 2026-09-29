# Connection name configured in your Looker Admin settings
connection: "looker_partner_demo"

# Includes all view files from subdirectories----manualjklihshsj
include: "/views/**/*.view.lkml"

include: "/tests/*.lkml"

# Inside your .model.lkml files:
include: "/Dashboard/*.dashboard.lookml"  # or include: "*.dashboard"


# February 1 fiscal start date
fiscal_month_offset: 1

datagroup: daily_etl_datagroup {
  # 1. Looker runs this query periodically to check for changes
  sql_trigger: SELECT MAX(id) FROM order_items ;;

  # 2. Maximum time cache/PDT stays valid if the trigger hasn't changed
  max_cache_age: "24 hours"
}
# Tells all explores in this model to use this datagroup by default
persist_with: daily_etl_datagroup



explore: order_items {
  label: "Executive Ecommerce Analysis"
  persist_with: daily_etl_datagroup

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} =${users.id} ;;

    # Overrides the underlying view's table dynamically based on mode
    from: users
    sql_table_name:
      {% if dev_mode %}
        (SELECT 1 AS id, 'Dev User' AS name)
      {% else %}
        `your_gcp_project.your_dataset.users`
      {% endif %} ;;
  }


  }
