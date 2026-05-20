{%- macro union_tables_by_table_pattern(schema_pattern, database, table_pattern) -%}

  {%- if not table_pattern -%}
    {{ exceptions.raise_compiler_error(
      "union_tables_by_table_pattern requires a table pattern. Run it like: "
      ~ "dbt run-operation union_tables_by_table_pattern --args "
      ~ "'{\"table_pattern\": \"orders%\", \"schema_pattern\": \"raw\", "
      ~ "\"database\": \"dbt_learn_jinja\"}'"
    ) }}
  {%- endif -%}

  {%- if not execute -%}
    {{ return('') }}
  {%- endif -%}

  {%- set tables = dbt_utils.get_relations_by_pattern(
    schema_pattern=schema_pattern,
    table_pattern=table_pattern,
    database=database
  ) -%}

  {%- if tables | length == 0 -%}
    {{ exceptions.raise_compiler_error(
      "No relations found for pattern '" ~ table_pattern ~ "' in " ~ database ~ "." ~ schema_pattern
    ) }}
  {%- endif -%}

  {%- set sql -%}
    {%- for table in tables -%}
      {%- if not loop.first %} union all {% endif -%}
      select * from {{ table }}
    {%- endfor -%}
  {%- endset -%}

  {{ log("Built union SQL for " ~ (tables | length) ~ " relation(s) in " ~ database ~ "." ~ schema_pattern, info=True) }}
  {{ return(sql) }}

{%- endmacro -%}
