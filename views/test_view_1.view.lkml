view: test_view_1 {
  sql_table_name: public.test ;;

  dimension: id {
    type: number
    primary_key: yes
    sql: ${TABLE}.id ;;
    label: "ID"
    description: "Unique identifier"
  }

  dimension: name {
    type: string
    sql: ${TABLE}.id ;;
    label: "ID"
    description: "name test"
  }

  measure: count {
    type: count
    label: "Count"
    description: "Total number of records"
  }
}
