{{
  config(
    materialized='table',
    unique_key='list_price_id'
  )
}}
select
  account_id,
  price_start_time,
  price_end_time,
  sku_name,
  cloud,
  currency_code,
  usage_unit,
  pricing.default as default_price,
  {{ dbt_utils.generate_surrogate_key(['account_id', 'price_start_time', 'price_end_time', 'sku_name', 'cloud', 'currency_code', 'usage_unit']) }} as list_price_id
from
  {{ source('databricks_billing', 'list_prices') }}
order by
  price_start_time asc
