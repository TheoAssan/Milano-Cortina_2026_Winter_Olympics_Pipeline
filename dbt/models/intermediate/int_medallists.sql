with medallists as (
    select * from {{ ref("stg_Milano_26__medallists_winter26") }}
),

events as (
    select * from {{ref("dim_events")}}
),

renamed as (
    select 
        m.*,
        e.event_id
    from medallists m 
    left join events e on m.event_name = e.event_name 
    and m.discipline_code = e.discipline_code
    and m.gender = e.gender
)

select * from renamed 