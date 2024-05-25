{{
  config(
    materialized='incremental'
  )
}}
select
  event_time,
  account_id,
  workspace_id,
  warehouse_id,
  event_type,
  cluster_count
from
  {{ source('databricks_compute', 'warehouse_events') }}
{% if is_incremental() %}
where
  event_time > (select coalesce(max(event_time), '1970-01-01'::date) from {{ this }})
{% endif %}
order by
  event_time asc
