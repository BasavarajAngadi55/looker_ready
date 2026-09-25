# =======================================================
# TEST 1: Check Primary Key Uniqueness in Users View
# Ensures no duplicate user IDs exist in the table
# =======================================================
test: user_id_is_unique {
  explore_source: order_items {
    column: id { field: users.id }
    column: count { field: users.count }
    sorts: [users.count: desc]
    limit: 1
  }
  assert: user_id_has_no_duplicates {
    expression: ${users.count} = 1 ;;
  }
}

# =======================================================
# TEST 2: Check Join Integrity between Order Items and Users
# Ensures every order_item belongs to a valid user ID (no orphans)
# =======================================================
test: no_orphaned_order_items {
  explore_source: order_items {
    column: order_item_id { field: order_items.id }
    column: user_id { field: order_items.user_id }
    filters: [users.id: "NULL"]
  }
  assert: order_items_have_valid_user {
    expression: ${order_items.count} = 0 ;;
  }
}
