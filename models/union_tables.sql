{#{ union_tables_by_prefix(table_pattern="orders*", schema="dbt_learn_jinja", database="raw") }#}
{#  {{  dbt_utils.get_relations_by_pattern(schema_pattern="dbt_learn_jinja", table_pattern="orders%", database="raw") }}  #}
{{ union_tables_by_table_pattern(schema_pattern="dbt_learn_jinja", database=target.database, table_pattern="orders%") }}