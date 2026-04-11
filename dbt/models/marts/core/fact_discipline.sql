-- fact_disc.sql
with medallists as (
    select * from {{ ref('fact_athlete_perf') }}
),

countries as (
    select country_code, country_name from {{ ref('dim_countries') }}
),

aggregated as (
    select
        m.country_code,
        c.country_name,
        m.discipline_code,
        m.discipline_name,
        m.medal,
        count(distinct m.event_id)    as medal_count
    from medallists m
    left join countries c on m.country_code = c.country_code
    group by 1, 2, 3, 4, 5
)

select * from aggregated