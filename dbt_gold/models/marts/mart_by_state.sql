SELECT
    state,
    COUNT(*) AS total_breweries,
    COUNT(DISTINCT city) as total_cities,
    COUNT(CASE WHEN website_url IS NOT NULL
        THEN 1 END) AS breweries_with_website,
    ROUND(
        COUNT(CASE WHEN website_url IS NOT NULL
            THEN 1 END) * 100.0
        / COUNT(*), 1    
    ) as pct_with_website
FROM {{ ref('stg_breweries') }}
GROUP BY state
ORDER BY total_breweries DESC