{{
  config(
    materialized='incremental'
  )
}}
select
  account_id,
  workspace_id,
  cluster_id,
  cluster_name,
  owned_by,
  create_time,
  delete_time,
  driver_node_type,
  worker_node_type,
  worker_count,
  min_autoscale_workers,
  max_autoscale_workers,
  auto_termination_minutes,
  enable_elastic_disk,
  cluster_source,
  driver_instance_pool_id,
  worker_instance_pool_id,
  dbr_version,
  change_time,
  change_date,
  tags
from
  {{ source('databricks_compute', 'clusters') }}
{% if is_incremental() %}
where
  change_time > (select coalesce(max(change_time), '1970-01-01'::date) from {{ this }})
{% endif %}
order by
  change_time asc
