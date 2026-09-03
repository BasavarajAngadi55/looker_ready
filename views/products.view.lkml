include: "/views/base_events.view.lkml"

view: products {
  # Inherits created_at and updated_at date groups from base_events
  extends: [base_events]
  sql_table_name: `products` ;;

  # primary_key: yes tells Looker this column uniquely identifies every row.
  # CRITICAL for Looker to avoid fan-out errors during SQL JOINs!
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
    # Action Link: Allows users to right-click/click a product on the dashboard
    # to search Google directly
    link: {
      label: "Search Product on Google"
      url: "https://www.google.com/search?q={{ value }}"
      icon_url: "https://google.com/favicon.ico"
    }
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;

    link: {
      label: "View Category Overview"
      url: "/dashboards/YOUR_DASHBOARD_ID?Category={{ value | url_encode }}"
    }
  }


  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: retail_price {
    type: number
    value_format_name: usd # Formats raw numbers as $1,234.56 on dashboards
    sql: ${TABLE}.retail_price ;;
  }
}
