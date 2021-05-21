connection: "bigquery_4pics"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

# datagroup: dash_rev_datagroup {
#   # sql_trigger: SELECT MAX(id) FROM etl_log;;
#   max_cache_age: "1 hour"
# }



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



###################ENHANCEMENT OH THE DASH LEVEL NOT FINISHED########################



# Place in `4picsmodel` model
  # explore: +events_4pics {
  #   aggregate_table: rollup__days_since_first_touch__0 {
  #     query: {

  #       dimensions: [days_since_first_touch]
  #       measures: [average_ad_revenue_per_user, average_iap_revenue_per_user]
  #       filters: [
  #         events_4pics.days_since_first_touch: "[0, 3]",
  #         events_4pics.event_date: "3 days ago for 3 days"
  #       ]

  #     }
  #     materialization: {datagroup_trigger:dash_rev_datagroup}

  #     # Please specify a datagroup_trigger or sql_trigger_value
  #     # See https://looker.com/docs/r/lookml/types/aggregate_table/materialization
  #   }

  #   aggregate_table: rollup__ad_revenue__iap_revenue__1 {
  #     query: {
  #       measures: [ad_revenue, iap_revenue]
  #       filters: [events_4pics.event_date: "2 days ago for 2 days"]
  #     }

  #     # Please specify a datagroup_trigger or sql_trigger_value
  #     # See https://looker.com/docs/r/lookml/types/aggregate_table/materialization
  #   }
  # }
}
