with athletes as (
    select distinct country_code from {{ref("stg_Milano_26__athletes_winter26")}}
),

codes_lookup as (
    select 
        country_code,
        country_name
    from {{ ref('ioc_codes') }}
)

select  
    a.country_code,
    c.country_name
from athletes a 
left join codes_lookup c on a.country_code = c.country_code
order by a.country_code asc 