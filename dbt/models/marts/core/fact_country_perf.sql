-- fact_country_perf.sql
with countries as (
    select * from {{ ref('dim_countries') }}
),

ain_medals as (
    select
        country_code,
        sum(case when medal = 'GOLD' then medal_count else 0 end)     as gold,
        sum(case when medal = 'SILVER' then medal_count else 0 end)   as silver,
        sum(case when medal = 'BRONZE' then medal_count else 0 end)   as bronze,
        sum(medal_count)                                               as total,
        null                                                           as rank,
        null                                                           as rank_total
    from {{ ref('fact_discipline') }}
    where country_code = 'AIN'
    group by 1
),

medals as (
    select country_code, gold, silver, bronze, total, rank, rank_total
    from {{ ref('stg_Milano_26__medals_winter26') }}

    union all

    select * from ain_medals
),

athletes as (
    select
        country_code,
        count(distinct athlete_code)    as total_athletes
    from {{ ref('dim_athletes') }}
    group by country_code
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
        coalesce(a.total_athletes, 0)   as total_athletes,
        case 
            when m.country_code is not null then true 
            else false 
        end                             as won_medal,
        round(
            coalesce(m.total, 0) / nullif(a.total_athletes, 0) * 100, 2
        )                               as conversion_rate
    from countries c
    left join medals m      on c.country_code = m.country_code
    left join athletes a    on c.country_code = a.country_code
)

select * from joined