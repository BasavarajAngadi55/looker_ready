---
- dashboard: www
  title: www
  preferred_viewer: dashboards-next
  description: ''
  preferred_slug: GDp6FOzxQA3iTuqfjNJKDW
  theme_name: ''
  layout_granularity: granular
  layout: newspaper
  tabs:
  - name: ''
    label: ''
  elements:
  - title: www
    name: www
    model: ecommerce
    explore: fact_sales
    type: table
    fields: [cat.category_id, cat.category_name, store.store_id, fact_sales.total_sales,
      fact_category_targets.total_category_target, prod.product_id]
    sorts: [fact_sales.total_sales desc]
    limit: 500
    column_limit: 50
    total: true
    row: 0
    col: 0
    width: 24
    height: 12
    tab_name: ''
