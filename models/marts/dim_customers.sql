with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customer_id,
        count(*)             as number_of_orders,
        sum(order_total)     as lifetime_value,
        min(ordered_at)      as first_order_at,
        max(ordered_at)      as most_recent_order_at
    from orders
    group by 1
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    c.created_at,
    coalesce(co.number_of_orders, 0)  as number_of_orders,
    coalesce(co.lifetime_value, 0)    as lifetime_value,
    co.first_order_at,
    co.most_recent_order_at
from customers c
left join customer_orders co
    on c.customer_id = co.customer_id
