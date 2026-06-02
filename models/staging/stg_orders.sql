with source as (
    select * from {{ source('raw', 'orders') }}
),

renamed as (
    select
        id                as order_id,
        customer_id       as customer_id,
        order_status      as order_status,
        order_total       as order_total,
        ordered_at        as ordered_at
    from source
)

select * from renamed
