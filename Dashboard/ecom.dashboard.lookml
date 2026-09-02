- dashboard: executive_overview
  title: "Executive Revenue & Operational Command Center"
  layout: grid
  rows:
    - elements: [kpi_total_revenue, kpi_return_rate, kpi_pop_growth]
      height: 130
    - elements: [chart_revenue_trend, chart_user_tier_pdt]
      height: 380
    - elements: [chart_top_categories, table_high_return_products]
      height: 420

  filters:
    - name: date_filter
      title: "Created Date Range"
      type: field_filter
      default_value: "30 days"
      model: ecommerce
      explore: order_items
      field: order_items.created_date

    - name: country_filter
      title: "User Country"
      type: field_filter
      default_value: "USA"
      model: ecommerce
      explore: order_items
      field: users.country

  elements:
    - name: kpi_total_revenue
      title: "Total Revenue"
      model: ecommerce
      explore: order_items
      type: single_value
      fields: [order_items.total_revenue]
      listen:
        date_filter: order_items.created_date
        country_filter: users.country

    - name: kpi_return_rate
      title: "Overall Return Rate"
      model: ecommerce
      explore: order_items
      type: single_value
      fields: [order_items.return_rate]
      listen:
        date_filter: order_items.created_date
        country_filter: users.country

    - name: kpi_pop_growth
      title: "Period-Over-Period Growth (30 Days)"
      model: ecommerce
      explore: order_items
      type: single_value
      fields: [order_items.pop_revenue_growth]

    - name: chart_revenue_trend
      title: "Daily Revenue Trend by Status"
      model: ecommerce
      explore: order_items
      type: looker_line
      fields: [order_items.created_date, order_items.status, order_items.total_revenue]
      pivots: [order_items.status]
      sorts: [order_items.created_date desc]
      listen:
        date_filter: order_items.created_date
        country_filter: users.country

    - name: chart_user_tier_pdt
      title: "Revenue by Customer Tier (PDT Accelerated)"
      model: ecommerce
      explore: order_items
      type: looker_pie
      fields: [user_summary_pdt.user_tier, order_items.total_revenue]
      sorts: [order_items.total_revenue desc]


    - name: chart_top_categories
      title: "Category Revenue by Price Tier"
      model: ecommerce
      explore: order_items
      type: looker_column
      fields: [products.category, order_items.price_tier, order_items.total_revenue]
      pivots: [order_items.price_tier]
      sorts: [order_items.total_revenue desc]
      limit: 10
      listen:
        date_filter: order_items.created_date
        country_filter: users.country

    - name: table_high_return_products
      title: "High Return Rate Items (Refinement & HTML Rules)"
      model: ecommerce
      explore: order_items
      type: looker_grid
      fields: [products.name, products.category, order_items.total_revenue, order_items.returned_revenue, order_items.return_rate]
      sorts: [order_items.return_rate desc]
      limit: 10
      listen:
        date_filter: order_items.created_date
        country_filter: users.country
