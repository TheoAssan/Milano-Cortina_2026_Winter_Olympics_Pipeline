-- fct_schedule.sql
with schedules as (
    select * from {{ ref('stg_Milano_26__schedules_winter26') }}
),

events as (
    select
        event_id,
        event_name,
        gender,
        discipline_code,
        event_type
    from {{ ref('dim_events') }}
),

discipline as (
    select
        discipline_code,
        discipline
    from {{ ref('dim_discipline') }}
),

joined as (
    select
        s.event_start,
        s.event_end,
        s.day,
        s.status,
        s.discipline_code,
        d.discipline,
        s.event_name,
        e.event_id,
        s.event_type,
        s.event_medal,
        s.phase,
        s.gender,
        s.venue,
        s.venue_code,
        s.location,
        s.location_code,
        s.id                        as schedule_id,
        count(s.id) over (
            partition by s.discipline_code
        )                           as events_per_discipline,
        count(s.id) over (
            partition by cast(s.event_start as date)
        )                           as events_per_day
    from schedules s
    left join discipline d  on s.discipline_code = d.discipline_code
    left join events e      on s.event_name = e.event_name
                           and s.discipline_code = e.discipline_code
                           and s.gender = e.gender
)

select * from joined