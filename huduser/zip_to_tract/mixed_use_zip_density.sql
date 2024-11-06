-- address_density_hotspots.sql
--
-- Business Purpose: Identify high-density mixed-use areas by analyzing ZIP codes where both residential 
-- and business ratios are significant. This helps:
-- - Urban development planning
-- - Retail site selection
-- - Healthcare facility placement
-- - Service delivery optimization

WITH latest_data AS (
    -- Get most recent crosswalk data
    SELECT *
    FROM mimi_ws_1.huduser.zip_to_tract
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.huduser.zip_to_tract)
),

zip_metrics AS (
    -- Calculate density metrics by ZIP
    SELECT 
        zip,
        usps_zip_pref_city,
        usps_zip_pref_state,
        COUNT(DISTINCT tract) as tract_count,
        AVG(res_ratio) as avg_res_density,
        AVG(bus_ratio) as avg_bus_density,
        SUM(CASE WHEN res_ratio > 0.2 AND bus_ratio > 0.2 THEN 1 ELSE 0 END) as mixed_use_tracts
    FROM latest_data
    GROUP BY 1,2,3
)

SELECT 
    zip,
    usps_zip_pref_city,
    usps_zip_pref_state,
    tract_count,
    ROUND(avg_res_density, 3) as avg_residential_density,
    ROUND(avg_bus_density, 3) as avg_business_density,
    mixed_use_tracts,
    ROUND(mixed_use_tracts::FLOAT / tract_count, 2) as mixed_use_ratio
FROM zip_metrics 
WHERE tract_count > 1  -- Focus on ZIPs spanning multiple tracts
  AND avg_res_density > 0.1  -- Minimum residential presence
  AND avg_bus_density > 0.1  -- Minimum business presence
ORDER BY mixed_use_ratio DESC, tract_count DESC
LIMIT 100;

/* How this works:
1. First CTE gets the latest snapshot of ZIP-tract mappings
2. Second CTE calculates key metrics per ZIP code
3. Final query filters and ranks results based on mixed-use characteristics

Key metrics:
- tract_count: Number of Census tracts in each ZIP
- avg_res_density: Average residential ratio across tracts
- avg_bus_density: Average business ratio across tracts
- mixed_use_tracts: Count of tracts with significant residential and business presence
- mixed_use_ratio: Proportion of tracts that are mixed-use

Assumptions and limitations:
- Uses most recent data snapshot only
- Defines "significant" presence as > 0.2 ratio
- Limited to ZIPs with multiple tracts
- Does not account for absolute address counts

Possible extensions:
1. Add year-over-year trend analysis
2. Include total address counts for volume context
3. Add geographic clustering analysis
4. Create density tiers/categories
5. Incorporate demographic or economic data
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:55:07.624130
    - Additional Notes: Query identifies high-density mixed-use ZIP codes based on residential and business address ratios. Best used for urban planning and site selection analysis. Note that results are limited to the most recent data snapshot and may not reflect historical patterns.
    
    */