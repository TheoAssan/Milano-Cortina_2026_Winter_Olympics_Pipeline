with schedules as (
    select * from {{ref("stg_Milano_26__schedules_winter26")}}
),

events as (
    select 
        distinct {{ dbt_utils.generate_surrogate_key(
            ['discipline_code', 'event_name', 'gender']
        ) }}         AS event_id,
        event_name,
        gender,
        discipline_code      
    from schedules
)

select * from events 
