connection: "bigquery_4pics"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project



named_value_format: large_eur { value_format: "[>=1000000]\"€\"0.00,,\"M\";[>=1000]\"€\"0.00,\"K\";\"€\"0.00" }
named_value_format: large_number { value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.00,\"K\";0" }
named_value_format: large_usd { value_format: "[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";\"$\"0.00" }

explore: events_4pics {
label: "4pics"
always_filter: {
  filters: [events_4pics.event_date: "2 days ago for 2 days"]
}

  join: events_4pics__items {
    view_label: "Events: Items"
    sql: LEFT JOIN UNNEST(${events_4pics.items}) as events_4pics__items ;;
    relationship: one_to_many
  }
}
