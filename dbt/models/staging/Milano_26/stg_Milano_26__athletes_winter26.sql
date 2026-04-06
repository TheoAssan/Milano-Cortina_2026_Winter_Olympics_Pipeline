with 

source as (

    select * from {{ source('Milano_26', 'athletes_winter26') }}

),

renamed as (

    select
        cast(code as integer) as athlete_code,
        cast(name as string) as athlete_name,
        upper(cast(gender as string)) as gender,
        upper(cast(country_code as string)) as country_code,
        flag_bearer,
        events

    from source

)

select * from renamed