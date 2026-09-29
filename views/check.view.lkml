view: check {
  parameter: select_environment {
    type: unquoted
    default_value: "prod"
    allowed_value: {
      label: "Dev Mode"
      value: "dev"
    }
    allowed_value: {
      label: "Prod Mode"
      value: "prod"
    }
  }

  sql_table_name:
    {% if select_environment._parameter_value == 'dev' %}
      (SELECT 1 AS id, 'Dev Mode Active' AS environment)
    {% else %}
      (SELECT 100 AS id, 'Prod Mode Active' AS environment)
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
