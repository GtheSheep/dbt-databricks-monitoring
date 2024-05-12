{{
  config(
    materialized='incremental',
    unique_key='record_id'
  )
}}
select
  record_id,
  record_type,
  account_id,
  workspace_id,
  billing_origin_product,
  sku_name,
  cloud,
  usage_type,
  usage_start_time,
  usage_end_time,
  usage_date,
  usage_unit,
  usage_quantity,
  ingestion_date,
  identity_metadata.run_as as run_as,
  usage_metadata.warehouse_id as warehouse_id,
  usage_metadata.instance_pool_id as instance_pool_id,
  usage_metadata.cluster_id as cluster_id,
  usage_metadata.node_type as node_type,
  usage_metadata.job_id as job_id,
  usage_metadata.job_run_id as job_run_id,
  usage_metadata.notebook_id as notebook_id,
  usage_metadata.dlt_pipeline_id as dlt_pipeline_id,
  product_features.is_serverless as is_serverless,
  product_features.is_photon as is_photon,
  product_features.serving_type as serving_type,
  product_features.dlt_tier as dlt_tier,
  product_features.jobs_tier as jobs_tier,
  product_features.sql_tier as sql_tier,
  custom_tags
from
  {{ source('databricks_billing', 'usage') }}
{% if is_incremental() %}
where
  usage_start_time >= (select coalesce(max(usage_start_time), '1970-01-01'::date) from {{ this }})
{% endif %}
order by
  usage_start_time asc
