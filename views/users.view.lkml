view: users {
  sql_table_name: `users` ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # hidden: yes keeps raw first/last name out of the field picker to avoid visual clutter
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



      measure: total_registered_users {
        type: number
        sql: (SELECT COUNT(DISTINCT id) FROM ${TABLE}) ;;
        description: "Total count of all registered users regardless of order history"
      }

}
