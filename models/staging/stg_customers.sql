with source as (
    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        id                as customer_id,
        first_name        as first_name,
        last_name         as last_name,
        email             as email,
        created_at        as created_at
    from source
)

select * from renamed
