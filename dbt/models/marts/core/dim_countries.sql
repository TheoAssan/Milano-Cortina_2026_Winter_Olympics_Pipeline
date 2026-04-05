with medallists as (
    select * from {{ref("stg_Milano_26__medallists_winter26")}}
)

countries as (
    select distinct(
        country_code,
        country
    ) 
    from {{ref("stg_Milano_26__medallists_winter26")}}
)

select * from countries 