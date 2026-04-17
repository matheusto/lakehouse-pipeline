SELECT
    brewery_type,
    COUNT(*) AS total_breweries,
    COUNT(DISTINCT state) AS states_present,
    COUNT(DISTINCT city) AS cities_present
FROM {{ref('stg_breweries')}}
GROUP BY brewery_type
ORDER BY total_breweries DESC