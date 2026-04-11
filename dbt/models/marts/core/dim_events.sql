with schedules as (
    select * from {{ ref("stg_Milano_26__schedules_winter26") }}
),

events as (
    select 
        distinct
        event_name,
        gender,
        discipline_code,
        event_type     
    from schedules
),

expanded as (
    select event_name, discipline_code, event_type, 'M' as gender from events where gender in ('X', 'G')
    union distinct
    select event_name, discipline_code, event_type, 'F' as gender from events where gender in ('X', 'G')
    union distinct
    select event_name, discipline_code, event_type, 'F' as gender from events where gender = 'W'
    union distinct
    select event_name, discipline_code, event_type, 'M' as gender from events where gender = 'M'
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(
            ['discipline_code', 'event_name']
        ) }} as event_id,
        event_name,
        gender,
        discipline_code,
        event_type
    from expanded
)

select * from final