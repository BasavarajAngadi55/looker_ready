view: users {
  # Dynamically points to the dataset assigned to the logged-in user
  sql_table_name: `{{ _user_attributes['gcp_dataset_name'] }}.users` ;;

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

  measure: count {
    type: count_distinct
    sql: ${id} ;;
    description: "Distinct count of user IDs"
  }

  measure: total_registered_users {
    type: count
    description: "Total count of registered user records"
  }
}
