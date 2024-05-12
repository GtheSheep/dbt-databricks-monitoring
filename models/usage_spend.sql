{{
  config(
    materialized='incremental',
    unique_key='record_id'
  )
}},
usage as (
  select
    *
  from
    {{ ref('stg_billing__usage') }}
  {% if is_incremental() %}
  where
    usage_start_time >= (select coalesce(max(usage_start_time), '1970-01-01'::date) from {{ this }})
  {% endif %}
),
list_prices as (
  select
    *
  from
    {{ ref('stg_billing__list_prices') }}
),
final as (
  select
    usage.*
    list_prices.default_price,
    list_prices.list_price_id,
    usage.usage_quantity * list_prices.default_price as spend
  from
    usage
  inner join
    list_prices
    on usage.sku_name = list_prices.sku_name
      and usage.usage_end_time >= list_prices.price_start_time
      and (list_prices.price_end_time is null or usage.usage_end_time < list_prices.price_end_time)
)
select
  *
from
  final
