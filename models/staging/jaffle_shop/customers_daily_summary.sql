
with orders_per_customer
(select 
{{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} as primary_key,
customer_id,
order_date,
count(*) as c

from {{ ref('stg_jaffle_shop_orders') }}
group by 1,2,3
order by 4 desc)
SELECT * FROM orders_per_customer