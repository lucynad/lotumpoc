# Un-hide and use this explore, or copy the joins into another explore, to get all the fully nested relationships from this view


view: events_4pics {
  sql_table_name: `pics-8f026.analytics_152614251.events_*`
    ;;

  dimension: ga_session_id {
    # NOT UNIQUE ACROSS USERS - for unique session ID concat with user_id
    label: "GA Sesssion ID"
    type: string
    sql:
         (SELECT value.int_value
             FROM UNNEST(${event_params})
             WHERE key = 'ga_session_id')
        ;;
  }

  measure: number_of_sessions {
    type: count_distinct
    # for more accuracy use unique session ID not GA
    sql: ${ga_session_id} ;;
  }

  dimension: entrences {
    type: string
    sql:
    CASE WHEN ${event_name} = "screen_view" THEN
         (SELECT value.int_value
             FROM UNNEST(${event_params})
             WHERE key = 'ga_session_id')
       END ;;
  }

#########Monetization########################

  dimension: is_iap_purchase {
    type: yesno
    hidden: yes
    sql: ${event_name} = 'in_app_purchase' ;;
  }

measure: iap_revenue {
  label: "Total IAP Revenue"
  group_label: "Monetization"
  description: "Total Revenue from In-App Purchases"
  type: sum
  sql: ${user_ltv__revenue} ;;
  filters: [is_iap_purchase: "yes"]
  value_format_name: large_usd
}
              #ads revenue

  dimension: is_ad_paid_event {
    type: yesno
    hidden: yes
    sql: ${event_name} = 'ad_paid_event' ;;
  }
  measure: ad_revenue {
    label: "Total Ad Revenue"
    group_label: "Monetization"
    description: "Total Revenue from Adds"
    type: sum
    sql: ${user_ltv__revenue} ;;
    filters: [is_ad_paid_event: "yes"]
    value_format_name: large_usd
  }

################ IAP Revenue per user #########################
  measure: average_iap_revenue_per_user {
    group_label: "Monetization"
    label: "ARPU - IAP"
    description: "(Average revenue per user) = Total IAP Revenue / Total Number of Users"
    type: number
    sql: 1.0 * ${iap_revenue} / NULLIF(${number_of_users},0) ;;
    value_format_name: large_usd
    drill_fields: [drill_field,average_iap_revenue_per_user]
  }

  ############## Average Ad Revenue per user ###################
  measure: average_ad_revenue_per_user {
    group_label: "Monetization"
    label: "ARPU - Ads"
    description: "(Average revenue per user) = Ad Revenue / Total Number of Users"
    type: number
    sql: 1.0 * ${ad_revenue} / NULLIF(${number_of_users},0) ;;
    value_format_name: large_usd
    drill_fields: [drill_field,average_ad_revenue_per_user]
  }


  ############## Calculating combined IAP + AD Revenue###############

  measure: combined_revenue {
    type: number
    sql: IFNULL(${iap_revenue},0) + IFNULL(${ad_revenue},0) ;;
    value_format_name: large_usd
  }

  measure: total_revenue {
    group_label: "Monetization"
    description: "IAP + Ad Revenue"
    type: sum
    sql: ${combined_revenue} ;;
    value_format_name: large_usd
    drill_fields: [drill_field,total_revenue]
  }





######### Retention Analysis##########

  dimension_group: user_first_touch {
    description: "The time at which the user first opened the app."
    timeframes: [raw,time,hour,minute,date, week, day_of_week, month, year]
    type: time
    sql: TIMESTAMP_MICROS(${TABLE}.user_first_touch_timestamp) ;;
  }

######### Calculating the time intervals between events############
  dimension_group: since_first_touch {
    type: duration
    intervals: [day, week]
    sql_start: ${user_first_touch_raw} ;;
    sql_end: ${_event_raw} ;;
  }

######First visit on the app##########




########## Creating firebase_user_id to get count_distinct of users ##########
  dimension: firebase_user_id {
    description: "either user_id or user_pseudo_id"
    sql: COALESCE(${user_id},${user_pseudo_id}) ;;
  }

########## creating nnumber of users needed for retention ##############
  measure: number_of_users {
    type: count_distinct
    sql: ${firebase_user_id} ;;
  }

  ####### Used to calculate Installs ###########


  dimension: retention_day {
    group_label: "Retention"
    description: "Days since first seen (from event date)"
    type:  number
    sql:  DATE_DIFF(${event_date}, ${user_first_touch_date}, DAY);;
  }


  measure: number_of_new_users {
    description: "Start date = Play Date"
    type: count_distinct
    sql: ${user_id};;
    filters: [retention_day: "0"]
    value_format_name: large_number
    drill_fields: [detail*]
  }


  dimension: app_info__firebase_app_id {
    type: string
    sql: ${TABLE}.app_info.firebase_app_id ;;
    group_label: "App Info"
    group_item_label: "Firebase App ID"
  }

  dimension: app_info__id {
    type: string
    sql: ${TABLE}.app_info.id ;;
    group_label: "App Info"
    group_item_label: "ID"
  }

  dimension: app_info__install_source {
    type: string
    sql: ${TABLE}.app_info.install_source ;;
    group_label: "App Info"
    group_item_label: "Install Source"
  }

  dimension: app_info__install_store {
    type: string
    sql: ${TABLE}.app_info.install_store ;;
    group_label: "App Info"
    group_item_label: "Install Store"
  }

  dimension: app_info__version {
    type: string
    sql: ${TABLE}.app_info.version ;;
    group_label: "App Info"
    group_item_label: "Version"
  }

  dimension: device__advertising_id {
    type: string
    sql: ${TABLE}.device.advertising_id ;;
    group_label: "Device"
    group_item_label: "Advertising ID"
  }

  dimension: device__browser {
    type: string
    sql: ${TABLE}.device.browser ;;
    group_label: "Device"
    group_item_label: "Browser"
  }

  dimension: device__browser_version {
    type: string
    sql: ${TABLE}.device.browser_version ;;
    group_label: "Device"
    group_item_label: "Browser Version"
  }

  dimension: device__category {
    type: string
    sql: ${TABLE}.device.category ;;
    group_label: "Device"
    group_item_label: "Category"
  }

  dimension: device__is_limited_ad_tracking {
    type: string
    sql: ${TABLE}.device.is_limited_ad_tracking ;;
    group_label: "Device"
    group_item_label: "Is Limited Ad Tracking"
  }

  dimension: device__language {
    type: string
    sql: ${TABLE}.device.language ;;
    group_label: "Device"
    group_item_label: "Language"
  }

  dimension: device__mobile_brand_name {
    type: string
    sql: ${TABLE}.device.mobile_brand_name ;;
    group_label: "Device"
    group_item_label: "Mobile Brand Name"
  }

  dimension: device__mobile_marketing_name {
    type: string
    sql: ${TABLE}.device.mobile_marketing_name ;;
    group_label: "Device"
    group_item_label: "Mobile Marketing Name"
  }

  dimension: device__mobile_model_name {
    type: string
    sql: ${TABLE}.device.mobile_model_name ;;
    group_label: "Device"
    group_item_label: "Mobile Model Name"
  }

  dimension: device__mobile_os_hardware_model {
    type: string
    sql: ${TABLE}.device.mobile_os_hardware_model ;;
    group_label: "Device"
    group_item_label: "Mobile OS Hardware Model"
  }

  dimension: device__operating_system {
    type: string
    sql: ${TABLE}.device.operating_system ;;
    group_label: "Device"
    group_item_label: "Operating System"
  }

  dimension: device__operating_system_version {
    type: string
    sql: ${TABLE}.device.operating_system_version ;;
    group_label: "Device"
    group_item_label: "Operating System Version"
  }

  dimension: device__time_zone_offset_seconds {
    type: number
    sql: ${TABLE}.device.time_zone_offset_seconds ;;
    group_label: "Device"
    group_item_label: "Time Zone Offset Seconds"
  }

  dimension: device__vendor_id {
    type: string
    sql: ${TABLE}.device.vendor_id ;;
    group_label: "Device"
    group_item_label: "Vendor ID"
  }

  dimension: device__web_info__browser {
    type: string
    sql: ${TABLE}.device.web_info.browser ;;
    group_label: "Device Web Info"
    group_item_label: "Browser"
  }

  dimension: device__web_info__browser_version {
    type: string
    sql: ${TABLE}.device.web_info.browser_version ;;
    group_label: "Device Web Info"
    group_item_label: "Browser Version"
  }

  dimension: device__web_info__hostname {
    type: string
    sql: ${TABLE}.device.web_info.hostname ;;
    group_label: "Device Web Info"
    group_item_label: "Hostname"
  }

  dimension: ecommerce__purchase_revenue {
    type: number
    sql: ${TABLE}.ecommerce.purchase_revenue ;;
    group_label: "Ecommerce"
    group_item_label: "Purchase Revenue"
  }

 measure: Total_Revenue {
    type:sum
    sql: ${ecommerce__purchase_revenue};;
    value_format_name: eur
  }

  dimension: ecommerce__purchase_revenue_in_usd {
    type: number
    sql: ${TABLE}.ecommerce.purchase_revenue_in_usd ;;
    group_label: "Ecommerce"
    group_item_label: "Purchase Revenue In USD"
  }

  dimension: ecommerce__refund_value {
    type: number
    sql: ${TABLE}.ecommerce.refund_value ;;
    group_label: "Ecommerce"
    group_item_label: "Refund Value"
  }

  dimension: ecommerce__refund_value_in_usd {
    type: number
    sql: ${TABLE}.ecommerce.refund_value_in_usd ;;
    group_label: "Ecommerce"
    group_item_label: "Refund Value In USD"
  }

  dimension: ecommerce__shipping_value {
    type: number
    sql: ${TABLE}.ecommerce.shipping_value ;;
    group_label: "Ecommerce"
    group_item_label: "Shipping Value"
  }

  dimension: ecommerce__shipping_value_in_usd {
    type: number
    sql: ${TABLE}.ecommerce.shipping_value_in_usd ;;
    group_label: "Ecommerce"
    group_item_label: "Shipping Value In USD"
  }

  dimension: ecommerce__tax_value {
    type: number
    sql: ${TABLE}.ecommerce.tax_value ;;
    group_label: "Ecommerce"
    group_item_label: "Tax Value"
  }

  dimension: ecommerce__tax_value_in_usd {
    type: number
    sql: ${TABLE}.ecommerce.tax_value_in_usd ;;
    group_label: "Ecommerce"
    group_item_label: "Tax Value In USD"
  }

  dimension: ecommerce__total_item_quantity {
    type: number
    sql: ${TABLE}.ecommerce.total_item_quantity ;;
    group_label: "Ecommerce"
    group_item_label: "Total Item Quantity"
  }

  dimension: ecommerce__transaction_id {
    type: string
    sql: ${TABLE}.ecommerce.transaction_id ;;
    group_label: "Ecommerce"
    group_item_label: "Transaction ID"
  }

  dimension: ecommerce__unique_items {
    type: number
    sql: ${TABLE}.ecommerce.unique_items ;;
    group_label: "Ecommerce"
    group_item_label: "Unique Items"
  }

  dimension: event_bundle_sequence_id {
    type: number
    sql: ${TABLE}.event_bundle_sequence_id ;;
  }

  dimension_group: event {
    type: time
    timeframes: [date, week, day_of_week, month, year]
    sql: TIMESTAMP(PARSE_DATE('%Y%m%d', REGEXP_EXTRACT(_TABLE_SUFFIX,r'\d\d\d\d\d\d\d\d'))) ;;
  }

  dimension_group: _event {
    label: "Event"
    timeframes: [raw,time,hour,minute]
    type: time
    sql: TIMESTAMP_MICROS(${TABLE}.event_timestamp) ;;
  }


  dimension: event_dimensions__hostname {
    type: string
    sql: ${TABLE}.event_dimensions.hostname ;;
    group_label: "Event Dimensions"
    group_item_label: "Hostname"
  }

  dimension: event_name {
    type: string
    sql: ${TABLE}.event_name ;;
  }

  dimension: event_params {
    hidden: yes
    sql: ${TABLE}.event_params ;;
  }

  dimension: event_previous_timestamp {
    type: number
    sql: ${TABLE}.event_previous_timestamp ;;
  }

  dimension: event_server_timestamp_offset {
    type: number
    sql: ${TABLE}.event_server_timestamp_offset ;;
  }

  dimension: event_timestamp {
    type: number
    sql: ${TABLE}.event_timestamp ;;
  }

  dimension: event_value_in_usd {
    type: number
    sql: ${TABLE}.event_value_in_usd ;;
  }

  dimension: geo__city {
    type: string
    sql: ${TABLE}.geo.city ;;
    group_label: "Geo"
    group_item_label: "City"
  }

  dimension: geo__continent {
    type: string
    sql: ${TABLE}.geo.continent ;;
    group_label: "Geo"
    group_item_label: "Continent"
  }

  dimension: geo__country {
    type: string
    sql: ${TABLE}.geo.country ;;
    group_label: "Geo"
    group_item_label: "Country"
  }

  dimension: geo__metro {
    type: string
    sql: ${TABLE}.geo.metro ;;
    group_label: "Geo"
    group_item_label: "Metro"
  }

  dimension: geo__region {
    type: string
    sql: ${TABLE}.geo.region ;;
    group_label: "Geo"
    group_item_label: "Region"
  }

  dimension: geo__sub_continent {
    type: string
    sql: ${TABLE}.geo.sub_continent ;;
    group_label: "Geo"
    group_item_label: "Sub Continent"
  }

  dimension: items {
    hidden: yes
    sql: ${TABLE}.items ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: stream_id {
    type: string
    sql: ${TABLE}.stream_id ;;
  }

  dimension: traffic_source__medium {
    type: string
    sql: ${TABLE}.traffic_source.medium ;;
    group_label: "Traffic Source"
    group_item_label: "Medium"
  }

  dimension: traffic_source__name {
    type: string
    sql: ${TABLE}.traffic_source.name ;;
    group_label: "Traffic Source"
    group_item_label: "Name"
  }

  dimension: traffic_source__source {
    type: string
    sql: ${TABLE}.traffic_source.source ;;
    group_label: "Traffic Source"
    group_item_label: "Source"
  }

  dimension: user_first_touch_timestamp {
    type: number
    sql: ${TABLE}.user_first_touch_timestamp ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}.user_id ;;
  }

  dimension: user_ltv__currency {
    type: string
    sql: ${TABLE}.user_ltv.currency ;;
    group_label: "User Ltv"
    group_item_label: "Currency"
  }

  dimension: user_ltv__revenue {
    type: number
    sql: ${TABLE}.user_ltv.revenue ;;
    group_label: "User Ltv"
    group_item_label: "Revenue"
  }

  dimension: user_properties {
    hidden: yes
    sql: ${TABLE}.user_properties ;;
  }

  dimension: user_pseudo_id {
    type: string
    sql: ${TABLE}.user_pseudo_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      event_name,
      traffic_source__name,
      device__mobile_model_name,
      device__mobile_brand_name,
      device__web_info__hostname,
      event_dimensions__hostname,
      device__mobile_marketing_name
    ]
  }

  ###Drill Selector####
  parameter: drill_by {
    type: string
    default_value: "device_platform"
    allowed_value: { label: "Country" value: "geo__country" }
    allowed_value: { label: "Platform" value: "platform" }
    allowed_value: { label: "App Version" value: "app_info__version" }
    allowed_value: { label: "Traffic Source" value: "traffic_source__name" }
  }

  dimension: drill_field {
    hidden: yes
    type: string
    label_from_parameter: drill_by
    sql:
      {% case  drill_by._parameter_value %}
        {% when "'country'" %}
          ${TABLE}.geo.country
        {% when "'platform'" %}
          ${TABLE}.platform
        {% when "'app_info_version'" %}
          ${TABLE}.app_info.version
        {% when "'install_source'" %}
          ${TABLE}.traffic_source.source
        {% else %}
         null
      {% endcase %} ;;
  }
}

view: events_4pics__items {
  dimension: affiliation {
    type: string
    sql: ${TABLE}.affiliation ;;
  }

  dimension: coupon {
    type: string
    sql: ${TABLE}.coupon ;;
  }

  dimension: creative_name {
    type: string
    sql: ${TABLE}.creative_name ;;
  }

  dimension: creative_slot {
    type: string
    sql: ${TABLE}.creative_slot ;;
  }

  dimension: item_brand {
    type: string
    sql: ${TABLE}.item_brand ;;
  }

  dimension: item_category {
    type: string
    sql: ${TABLE}.item_category ;;
  }

  dimension: item_category2 {
    type: string
    sql: ${TABLE}.item_category2 ;;
  }

  dimension: item_category3 {
    type: string
    sql: ${TABLE}.item_category3 ;;
  }

  dimension: item_category4 {
    type: string
    sql: ${TABLE}.item_category4 ;;
  }

  dimension: item_category5 {
    type: string
    sql: ${TABLE}.item_category5 ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}.item_id ;;
  }

  dimension: item_list_id {
    type: string
    sql: ${TABLE}.item_list_id ;;
  }

  dimension: item_list_index {
    type: string
    sql: ${TABLE}.item_list_index ;;
  }

  dimension: item_list_name {
    type: string
    sql: ${TABLE}.item_list_name ;;
  }

  dimension: item_name {
    type: string
    sql: ${TABLE}.item_name ;;
  }

  dimension: item_refund {
    type: number
    sql: ${TABLE}.item_refund ;;
  }

  dimension: item_refund_in_usd {
    type: number
    sql: ${TABLE}.item_refund_in_usd ;;
  }

  dimension: item_revenue {
    type: number
    sql: ${TABLE}.item_revenue ;;
  }

  dimension: item_revenue_in_usd {
    type: number
    sql: ${TABLE}.item_revenue_in_usd ;;
  }

  dimension: item_variant {
    type: string
    sql: ${TABLE}.item_variant ;;
  }

  dimension: location_id {
    type: string
    sql: ${TABLE}.location_id ;;
  }

  dimension: price {
    type: number
    sql: ${TABLE}.price ;;
  }

  dimension: price_in_usd {
    type: number
    sql: ${TABLE}.price_in_usd ;;
  }

  dimension: promotion_id {
    type: string
    sql: ${TABLE}.promotion_id ;;
  }

  dimension: promotion_name {
    type: string
    sql: ${TABLE}.promotion_name ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }


}
