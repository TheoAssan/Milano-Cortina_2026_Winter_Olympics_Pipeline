with 

source as (

    select * from {{ source('Milano_26', 'medallists_winter26') }}

),

renamed as (

    select        
        cast(medal_code as integer) as medal_code,
        cast(medal as string) as medal,
        cast(code as integer) as athlete_id,
        cast(name as string) as athlete_name,
        upper(cast(gender as string)) as gender,
        upper(cast(country_code as string)) as country_code,
        cast(country as string) as country,
        cast(discipline as string) as discipline,
        cast(discipline_code as string) as discipline_code,
        cast(event_name as string) as event_name

    from source

)

select * from renamed