view: users {
  sql_table_name: `users` ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: first_name {
    type: string
    hidden: yes
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    hidden: yes
    sql: ${TABLE}.last_name ;;
  }

  # Primary count measure for user IDs
  measure: count {
    type: count_distinct
    sql: ${id} ;;
    description: "Distinct count of user IDs"
  }

  # Alternative count using standard count
  measure: total_registered_users {
    type: count
    description: "Total count of registered user records"
  }
}
