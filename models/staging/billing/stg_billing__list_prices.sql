{{
  config(
    materialized='incremental',
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
{% if is_incremental() %}
where
  price_start_time >= (select coalesce(max(price_start_time), '1970-01-01'::date) from {{ this }})
{% endif %}
order by
  price_start_time asc
