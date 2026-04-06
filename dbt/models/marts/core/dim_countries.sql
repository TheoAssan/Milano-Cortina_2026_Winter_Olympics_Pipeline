with medallists as (
    select * from {{ref("stg_Milano_26__medallists_winter26")}}
),

countries as (
    select 
        distinct country_code,
        {{gen_country_name(country_code)}}
    from medallists
    order by country_code asc 
)

select * from countries 