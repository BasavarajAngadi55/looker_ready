view: base_events {
  # Tells Looker NOT to make this view independently queryable in Explores
  extension: required

  # Creates a group of time dimensions from a single timestamp column
  dimension_group: created {
    type: time
    # Looker automatically generates SQL for each timeframe listed below
    timeframes: [raw, time, date, week, month, quarter, year, day_of_week]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}.updated_at ;;
  }
}
