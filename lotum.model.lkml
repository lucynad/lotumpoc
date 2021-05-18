connection: "bigquery_wordblitz"

include: "/views/*.view.lkml"      # include all views in the views/ folder in this project


named_value_format: large_eur { value_format: "[>=1000000]\"€\"0.00,,\"M\";[>=1000]\"€\"0.00,\"K\";\"€\"0.00" }
named_value_format: large_number { value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.00,\"K\";0" }

explore: events {
label: "wordblitz"
#Will apply filter automatically for created Explore, will pull data for one completed day
  always_filter: {
    filters: [events.event_date: "2 days ago for 2 day"]
  }

  join: events__items {
    view_label: "Events: Items"
    sql: LEFT JOIN UNNEST(${events.items}) as events__items ;;
    relationship: one_to_many
  }
}
