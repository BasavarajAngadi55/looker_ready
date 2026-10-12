

# =======================================================
# TEST 2: Order Items View Primary Key Uniqueness
# Ensures no duplicate order item IDs exist in the order_items table
# =======================================================
test: order_item_id_is_unique {
  explore_source: order_items {
    column: id { field: order_items.id }
    column: count { field: order_items.count }
    sorts: [order_items.count: desc]
    limit: 1
  }
  assert: order_item_id_has_no_duplicates {
    expression: ${order_items.count} = 1 ;;
  }
}
