with payments as 
(select * from {{ ref('stg_stripe__payments') }}
where status = lower('success')
),
{% set distinct_values_query %}
    SELECT DISTINCT payment_method
    FROM {{ ref('stg_stripe__payments') }}
    WHERE status = lower('success')
{% endset %}
{% if execute %}
    {% set distinct_values = run_query(distinct_values_query).rows %}
{% else %}
    {% set distinct_values = [] %}
{% endif %}

pivoted as 
(select 
    order_id
    {%- for row in distinct_values %}
    {%- set method = row[0] %}
    , sum(case when payment_method = '{{ method }}' then amount else 0 end) as {{ method }}_amount
    {%- endfor %}
 from payments
 group by 1)

select * from pivoted
