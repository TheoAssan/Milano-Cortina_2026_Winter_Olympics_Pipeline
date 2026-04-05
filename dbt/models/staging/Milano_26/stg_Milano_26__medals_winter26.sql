with 

source as (

    select * from {{ source('Milano_26', 'medals_winter26') }}

),

renamed as (

    select
        cast(country as string) as country,
        cast(country_code as string) as country_code,
        cast(gold as integer) as gold,
        cast(silver as integer) as silver,
        cast(bronze as integer) as bronze,
        cast(total as integer) as total,
        cast(rank as integer) as rank,
        cast(rank_total as integer) as rank_total

    from source

)

select * from renamed