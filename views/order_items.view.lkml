view: order_items {
  sql_table_name: `order_items` ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  # Foreign keys used for JOINing tables (hidden to clean up UI)
  dimension: user_id {
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: sale_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;; # e.g. 'Complete', 'Processing', 'Returned'
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  # Measure: Aggregates data (SQL COUNT)
  measure: count {
    type: count
    # drill_fields defines what detailed table pops up when a user clicks this count on a dashboard
    drill_fields: [id, order_id, users.name, products.name, sale_price]
  }

  # Measure: Sums up sale_price
  measure: total_revenue {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

# 2. Count of entities (e.g., users or orders)
  measure: total_users {
    type: count_distinct
    sql: ${user_id} ;;
  }

# 3. Average of the summed revenue per user
  measure: average_revenue_per_user {
    type: number
    sql: 1.0 * ${total_revenue} / NULLIF(${total_users}, 0) ;;
    value_format_name: usd
  }

  dimension: sales_tier {
    type: string
    sql: CASE
        WHEN ${sale_price} > 500 THEN 'High'
        WHEN ${sale_price} BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'Low'
       END ;;
  }
# Filter field exposed in the UI for filtering users by purchased product category
  filter: user_purchased_category_filter {
    type: string
    suggest_dimension: products.category
  }

  #  Hidden dimension generating the subquery
  dimension: user_has_purchased_category {
    type: yesno
    hidden: yes
    sql:
      ${user_id} IN (
        SELECT DISTINCT oi_sub.user_id
        FROM `order_items` oi_sub
        LEFT JOIN `products` p_sub ON oi_sub.product_id = p_sub.id
        WHERE {% condition user_purchased_category_filter %} p_sub.category {% endcondition %}
      ) ;;
  }

  # Measure for distinct orders count from the items level
  measure: order_count {
    type: count_distinct
    sql: ${order_id} ;;
  }

# Isolated metric for the single targeted tile
  measure: revenue_from_category_buyers {
    type: sum
    sql: ${sale_price} ;;
    filters: [user_has_purchased_category: "yes"]
    value_format_name: usd
  }
}
