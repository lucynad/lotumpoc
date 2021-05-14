connection: "bigquery_wordblitz"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: events {

# Will apply filter automatically for created Explore, will pull data for one completed day
  always_filter: {
    filters: [events.event_date: "1 days ago for 1 day"]
  }

  join: events__items {
    view_label: "Events: Items"
    sql: LEFT JOIN UNNEST(${events.items}) as events__items ;;
    relationship: one_to_many
  }
}
