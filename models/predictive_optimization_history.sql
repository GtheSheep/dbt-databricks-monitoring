{{
  config(
    materialized='incremental',
    unique_key='operation_id'
  )
}}
with final as (
  select
    *
  from
    {{ ref('stg_storage__predictive_optimization_operations_history') }}
  {% if is_incremental() %}
  where
    start_time >= (select coalesce(max(start_time), '1970-01-01'::date) from {{ this }})
  {% endif %}
)
select
  *
from
  final
