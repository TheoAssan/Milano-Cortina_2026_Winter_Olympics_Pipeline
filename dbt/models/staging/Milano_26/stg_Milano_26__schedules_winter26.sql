with 

source as (

    select * from {{ source('Milano_26', 'schedules_winter26') }}

),

renamed as (

    select
        cast(start_date as timestamp) as start_date,
        cast(end_date as timestamp) as end_date,
        day,
        status,
        discipline,
        discipline_code,
        event,
        event_medal,
        phase,
        gender,
        event_type,
        venue,
        venue_code,
        location,
        location_code,
        id

    from source

)

select * from renamed