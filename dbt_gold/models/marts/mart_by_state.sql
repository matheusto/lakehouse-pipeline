SELECT
    state,
    COUNT(*)                                        AS total_breweries,
    COUNT(DISTINCT city)                            AS total_cities,
    COUNT(CASE WHEN website_url IS NOT NULL
               THEN 1 END)                          AS breweries_with_website,
    ROUND(
        COUNT(CASE WHEN website_url IS NOT NULL
                   THEN 1 END) * 100.0
        / COUNT(*), 1
    )                                               AS pct_with_website

FROM {{ ref('stg_breweries') }}
WHERE country = 'United States'

GROUP BY state
ORDER BY total_breweries DESC