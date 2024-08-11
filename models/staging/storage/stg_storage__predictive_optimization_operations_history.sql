{{
  config(
    materialized='incremental',
    unique_key='operation_id'
  )
}}
select
  account_id,
  workspace_id,
  start_time,
  end_time,
  metastore_name,
  metastore_id,
  catalog_name,
  schema_name,
  table_name,
  table_id,
  operation_type,
  operation_id,
  operation_status,
  --COMPACTION
  operation_metrics.number_of_compacted_files as number_of_compacted_files,
  operation_metrics.amount_of_data_compacted_bytes as amount_of_data_compacted_bytes,
  operation_metrics.number_of_output_files as number_of_output_files,
  operation_metrics.amount_of_output_data_bytes as amount_of_output_data_bytes,
  --VACUUM
  operation_metrics.number_of_deleted_files as number_of_deleted_files,
  operation_metrics.amount_of_data_deleted_bytes as amount_of_data_deleted_bytes,
  usage_unit,
  usage_quantity
from
    {{ source('databricks_storage', 'predictive_optimization_operations_history') }}
{% if is_incremental() %}
where
  start_time >= (select coalesce(max(start_time), '1970-01-01'::date) from {{ this }})
{% endif %}
order by
  start_time asc
