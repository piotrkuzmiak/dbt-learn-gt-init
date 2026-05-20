{%- set database = target.database -%}
{%- set schema_pattern = target.schema -%}

with tables_to_clean as (
SELECT DISTINCT
    table_schema,
    table_name,
    CASE when  LOWER(table_type) like '%view%' THEN 'view' ELSE 'table' END AS drop_type,
    'DROP ' || drop_type || ' {{ database | upper }}.' || table_schema || '.' || table_name  || ';' AS drop_query,
    last_altered
FROM {{ database }}.information_schema.tables
WHERE table_schema ILIKE '{{ schema_pattern }}'

    AND last_altered >= CURRENT_DATE - INTERVAL 90 DAYS
ORDER BY last_altered DESC
)
select * from tables_to_clean

