with 

source as (

    select * from {{ source('Milano_26', 'schedules_winter26') }}

),

renamed as (

    select
        cast(start_date as timestamp) as event_start,
        cast(end_date as timestamp) as event_end,
        day,
        status,
        discipline,
        discipline_code,
        cast(event as string) as event_name,
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