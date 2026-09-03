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

  # Combines two columns into one clean dimension
  dimension: name {
    type: string
    sql: CONCAT(${first_name}, ' ', ${last_name}) ;;
    # Deep-link: Clicking a user's name navigates to a dedicated User Detail Dashboard
    link: {
      label: "User Detail Dashboard"
      url: "/dashboards/user_lookup?User%20ID={{ users.id._value }}"
    }
  }

  # Dynamic HTML Styling: Formats output with flags and colors directly on tiles
  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
    html:
      {% if value == 'USA' %}
        <span style="color: #2e7d32; font-weight: bold; background-color: #e8f5e9; padding: 2px 6px; border-radius: 4px;">🇺🇸 {{ value }}</span>
      {% else %}
        <span style="color: #333333;">🌐 {{ value }}</span>
      {% endif %} ;;
  }
}
