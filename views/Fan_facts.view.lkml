 # If necessary, uncomment the line below to include explore_source.
# include: "lotum.model.lkml"

view: fan_facts {
  derived_table: {

      sql:SELECT
    events.user_id  AS user_id,
    COUNT(DISTINCT REGEXP_EXTRACT(_TABLE_SUFFIX,r'\d\d\d\d\d\d\d\d')) AS active_days_last_7_days
FROM `lotum-wordblitz.analytics_180596626.events_*`
     AS events
    where ((( TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'\d\d\d\d\d\d\d\d')))  ) >= ((TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -7 DAY))) AND ( TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'\d\d\d\d\d\d\d\d')))  ) < ((TIMESTAMP_ADD(TIMESTAMP_ADD(TIMESTAMP_TRUNC(CURRENT_TIMESTAMP(), DAY), INTERVAL -7 DAY), INTERVAL 7 DAY)))))
    group by 1;;


    # explore_source: events {
    #   column: user_id {}
    #   column: active_days_last_5_days {}
    # }
  }

  dimension: user_id {
    primary_key: yes

  }

  dimension: active_days_last_7_days {
    type: number
  }

  dimension: is_a_fan {
    type: yesno
    sql: ${active_days_last_7_days}>=5 ;;
  }

  measure: count_of_fans {
    type: count
    filters: [is_a_fan: "yes"]
    drill_fields: [user_id]
  }

}
