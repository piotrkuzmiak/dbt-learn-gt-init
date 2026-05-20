{% macro clean_up_stale_models(database=target.database, schema_pattern=target.schema, days=7, dry_run=True) %}

{% set get_drop_commands_query %}
SELECT DISTINCT
    CASE WHEN lower(table_type) LIKE '%view%' THEN 'view' ELSE 'table' END AS drop_type,
    'DROP ' || CASE WHEN lower(table_type) LIKE '%view%' THEN 'view' ELSE 'table' END
        || ' {{ database | upper }}.' || table_schema || '.' || table_name || ';' AS drop_query,
    last_altered
FROM {{ database }}.information_schema.tables
WHERE table_schema ILIKE '{{ schema_pattern }}'

    AND last_altered >= CURRENT_DATE - INTERVAL {{ days }} DAYS
{% endset %}

{{ log('\nGenerating cleanup queries...\n', info=True) }}

{% set results = run_query(get_drop_commands_query) %}
{% set drop_queries = results.columns[1].values() if results is not none else [] %}

{% for query in drop_queries %}

    {{ log(query, info=True) }}
    {% if not dry_run %}
        {% do run_query(query) %}
    {% else %}
        {{ log("Dry run enabled - skipping execution of above query.", info=True) }}
    {% endif %}

{% endfor %}
{% endmacro %}
