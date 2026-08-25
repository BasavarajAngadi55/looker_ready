connection: "looker_partner_demo"

include: "/**/*.view.lkml"

datagroup: five_minute_cache {
  sql_trigger: SELECT FLOOR(UNIX_TIMESTAMP() / 300) ;; # Evaluates to a new number every 300 seconds (5 mins)
  max_cache_age: "5 minutes"
}


explore: order_items {
  persist_with: five_minute_cache

  join: add_a_unique_name_1787580935 {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.created_month} = ${add_a_unique_name_1787580935.created_month} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }

  join: products {
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.product_id} = ${products.id} ;;
  }

  join: ndt_top_ranking {
    type: left_outer
    relationship: many_to_one
    sql_on: ${products.brand} = ${ndt_top_ranking.brand_name} ;;
  }
}
