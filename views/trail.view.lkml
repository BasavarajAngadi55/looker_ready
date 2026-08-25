# If necessary, uncomment the line below to include explore_source.
# include: "Retails.model.lkml"

view: add_a_unique_name_1787580935 {
  derived_table: {
    explore_source: order_items {
      column: created_month {}
      column: count {}
    }
    # Persist the NDT into a physical PDT using your model-level datagroup
    datagroup_trigger: five_minute_cache
  }

  dimension: created_month {
    description: ""
    type: date_month
  }

  dimension: count {
    description: ""
    type: number
  }
}
