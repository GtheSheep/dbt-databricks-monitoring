{{
  config(
    materialized='incremental',
    unique_key='statement_id'
  )
}}
with dbt_queries as (
  select 
    statement_id,
    statement_text,
    total_duration_ms,
    start_time,
    end_time,
    update_time,
    compute_warehouse_id AS warehouse_id,
    try_parse_json(btrim(regexp_extract(statement_text, '\/\*(.*?)\*\/'), '*')) AS dbt_metadata -- could be better
  from
    {{ ref('stg_query__history') }}
  where
    client_application = 'Databricks Dbt'
    {% if is_incremental() %}
    and update_time > (select coalesce(max(update_time), '1970-01-01'::date) from {{ this }})
    {% endif %}
),
final as (
  select
    dbt_queries.statement_id,
    dbt_queries.statement_text,
    dbt_queries.start_time,
    dbt_queries.end_time,
    dbt_queries.update_time,
    dbt_queries.total_duration_ms,
    dbt_queries.warehouse_id,
    dbt_queries.dbt_metadata:dbt_version::string as dbt_version,
    dbt_queries.dbt_metadata:dbt_databricks_version::string as dbt_databricks_version,
    dbt_queries.dbt_metadata:target_name::string as target_name,
    dbt_queries.dbt_metadata:node_id::string as node_id,
    usage_spend.spend * dbt_queries.total_duration_ms / 3600000 as query_spend
  from
    {{ ref('usage_spend') }} -- needs an increment
  inner join
    dbt_queries
    on usage_spend.warehouse_id = dbt_queries.warehouse_id
      and usage_spend.usage_start_time <= dbt_queries.start_time
      and usage_spend.usage_end_time >= dbt_queries.end_time
)
select
  *
from
  final
