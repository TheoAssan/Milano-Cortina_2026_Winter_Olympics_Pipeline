with athletes as (
    select * from {{ref("stg_Milano_26__athletes_winter26")}}
),

athlete_info as (
    select 
        distinct athlete_code,
        athlete_name,
        gender,
        country_code
    from athletes
    order by athlete_code asc
)

select * from athlete_info