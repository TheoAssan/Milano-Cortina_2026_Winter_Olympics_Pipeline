-- fct_medallists.sql
with medallists as (
    select * from {{ ref('int_medallists') }}
),

athletes as (
    select 
        athlete_code,
        athlete_name,
        gender,
        country_code
    from {{ ref('dim_athletes') }}
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
        m.medal_code,
        m.medal,
        m.athlete_code,
        a.athlete_name,
        a.gender,
        a.country_code,
        m.discipline,
        m.discipline_code,
        d.discipline                as discipline_name,
        m.event_name,
        e.event_id,
        e.event_type,
        count(m.medal_code) over (
            partition by m.athlete_code
        )                           as athlete_total_medals,
        case 
            when count(m.medal_code) over (
                partition by m.athlete_code
            ) > 1 then true 
            else false 
        end                         as is_multi_medallist

    from medallists m
    left join athletes a    on m.athlete_code = a.athlete_code
    left join discipline d  on m.discipline_code = d.discipline_code
    left join events e      on m.event_name = e.event_name
                           and m.discipline_code = e.discipline_code
                           and m.gender = e.gender
)

select * from joined