SELECT
    id,
    name,
    brewery_type,
    city,
    INITCAP(state)      AS state,
    country,
    longitude,
    latitude,
    website_url
FROM {{ source('silver', 'breweries') }}
WHERE state IS NOT NULL
  AND brewery_type IS NOT NULL