-- fct_country_performance.sql
with countries as (
    select * from {{ ref('dim_countries') }}
),

medals as (
    select * from {{ ref('stg_Milano_26__medals_winter26') }}
),

athletes as (
    select
        country_code,
        count(distinct athlete_code) as total_athletes,
        count(distinct case when gender = 'M' then athlete_code end) as male_athletes,
        count(distinct case when gender = 'F' then athlete_code end) as female_athletes
    from {{ ref('dim_athletes') }}
    group by country_code
),

joined as (
    select
        c.country_code,
        c.country_name,
        coalesce(m.gold, 0)         as gold_medals,
        coalesce(m.silver, 0)       as silver_medals,
        coalesce(m.bronze, 0)       as bronze_medals,
        coalesce(m.total, 0)        as total_medals,
        coalesce(m.rank, null)      as medal_rank,
        coalesce(m.rank_total, null) as rank_total,
        coalesce(a.total_athletes, 0)   as total_athletes,
        coalesce(a.male_athletes, 0)    as male_athletes,
        coalesce(a.female_athletes, 0)  as female_athletes,
        case 
            when m.country_code is not null then true 
            else false 
        end as won_medal
    from countries c
    left join medals m      on c.country_code = m.country_code
    left join athletes a    on c.country_code = a.country_code
)

select * from joined