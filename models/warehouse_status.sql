{{
  config(
    materialized='table'
  )
}}
with warehouse_status as (
  select
    account_id,
    workspace_id,
    warehouse_id,
    cluster_count,
    event_time as valid_from,
    lead(event_time) over (partition by warehouse_id, cluster_count order by event_time asc) as valid_to
  from
    {{ ref('stg_compute__warehouse_events') }}
),
final as (
  select
    account_id,
    workspace_id,
    warehouse_id,
    cluster_count,
    valid_from,
    coalesce(valid_to, current_timestamp()) as valid_to
  from
    warehouse_status
)
select
  *
from
  final
order by
  valid_from asc
