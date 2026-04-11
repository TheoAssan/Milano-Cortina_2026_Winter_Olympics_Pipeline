-- fact_country_perf.sql
with countries as (
    select * from {{ ref('dim_countries') }}
),

medals as (
    select * from {{ ref('stg_Milano_26__medals_winter26') }}
),

joined as (
    select
        c.country_code,
        c.country_name,
        coalesce(m.gold, 0)             as gold_medals,
        coalesce(m.silver, 0)           as silver_medals,
        coalesce(m.bronze, 0)           as bronze_medals,
        coalesce(m.total, 0)            as total_medals,
        coalesce(m.rank, null)          as medal_rank,
        coalesce(m.rank_total, null)    as rank_total,
        case 
            when m.country_code is not null then true 
            else false 
        end                             as won_medal
    from countries c
    left join medals m on c.country_code = m.country_code
)

select * from joined