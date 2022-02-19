{{ config(materialized='table') }}

with tripdata as 
(
  select *,
    row_number() over(partition by pickup_datetime) as rn
  from {{ source('core','fhv_tripdata_2019') }} 
)
select
    -- identifiers
    {{ dbt_utils.surrogate_key(['Dispatching_base_num', 'lpep_pickup_datetime']) }} as tripid,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,
    
    -- timestamps
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    SR_Flag,
   
from tripdata
where rn = 1


-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=True) %}

  limit 100

{% endif %}