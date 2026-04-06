with schedules as (
    select * from {{ref("stg_Milano_26__schedules_winter26")}}
),

discipline as (
    select 
        distinct discipline_code,
        discipline
    from schedules
    order by discipline_code asc
)

select * from discipline