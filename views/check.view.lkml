view: test_dev_mode {
  sql_table_name:
    {% if dev_mode %}
      (SELECT 1 AS id, 'Dev Data - Row 1' AS environment)
    {% else %}
      (SELECT 100 AS id, 'Prod Data - Row 1' AS environment)
    {% endif %} ;;

  dimension: id {
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: environment {
    type: string
    sql: ${TABLE}.environment ;;
  }
}
