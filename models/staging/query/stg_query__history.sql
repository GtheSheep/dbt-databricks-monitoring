{{
  config(
    materialized='incremental'
  )
}}
select
    account_id,
    workspace_id,
    statement_id,
    session_id,
    execution_status,
    compute.type as compute_type,
    compute.cluster_id as compute_cluster_id,
    compute.warehouse_id as compute_warehouse_id,
    executed_by_user_id,
    executed_by,
    statement_text,
    statement_type,
    error_message,
    client_application,
    client_driver,
    total_duration_ms,
    waiting_for_compute_duration_ms,
    waiting_at_capacity_duration_ms,
    execution_duration_ms,
    compilation_duration_ms,
    total_task_duration_ms,
    result_fetch_duration_ms,
    start_time,
    end_time,
    update_time,
    read_partitions,
    pruned_files,
    read_files,
    read_rows,
    produced_rows,
    read_bytes,
    read_io_cache_percent,
    from_result_cache,
    spilled_local_bytes,
    written_bytes,
    shuffle_read_bytes,
    query_source,
    executed_as,
    executed_as_user_id
from
  {{ source('databricks_query', 'history') }}
{% if is_incremental() %}
where
  update_time > (select coalesce(max(update_time), '1970-01-01'::date) from {{ this }})
{% endif %}
order by
  update_time asc
