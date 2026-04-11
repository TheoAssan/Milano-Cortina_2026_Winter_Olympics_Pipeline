with athletes as (
    select * from {{ref("stg_Milano_26__athletes_winter26")}}
),
countries as (
    select * from {{ ref('dim_countries') }}
),

athlete_info as (
    select 
        distinct a.athlete_code,
        a.athlete_name,
        a.gender,
        a.country_code,
        c.country_name
    from athletes a
    left join countries c on a.country_code = c.country_code
    order by athlete_code asc
)

select * from athlete_info