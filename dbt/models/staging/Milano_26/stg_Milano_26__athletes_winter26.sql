with 

source as (

    select * from {{ source('Milano_26', 'athletes_winter26') }}

),

renamed as (

    select
        code,
        name,
        gender,
        country_code,
        flag_bearer,
        events

    from source

)

select * from renamed