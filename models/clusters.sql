{{
  config(
    materialized='incremental',
    unique_key='cluster_id'
  )
}}
with final as (
  select
    *
  from
    {{ ref('stg_compute__clusters') }}
  {% if is_incremental() %}
  where
    change_time > (select coalesce(max(change_time), '1970-01-01'::date) from {{ this }})
  {% endif %}
  qualify
    row_number() over (partition by cluster_id order by change_time desc) = 1
)
select
  *
from
  final
