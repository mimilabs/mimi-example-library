/*
ZIP Code Residential Density Analysis for Market Segmentation
===========================================================

Business Purpose: 
This query identifies high-density residential areas by analyzing the residential ratio 
patterns within ZIP codes. This information is valuable for:
- Retail location planning
- Healthcare facility placement
- Marketing campaign targeting
- Service area optimization

The analysis focuses on ZIP codes with the highest concentration of residential addresses
to help businesses make data-driven decisions about market expansion and resource allocation.
*/

-- Main Query
WITH residential_density AS (
    SELECT 
        zip,
        usps_zip_pref_city,
        usps_zip_pref_state,
        -- Calculate average residential ratio per ZIP
        AVG(res_ratio) as avg_res_ratio,
        -- Count number of associated census tracts
        COUNT(DISTINCT tract) as tract_count,
        -- Sum total ratio to understand coverage
        SUM(tot_ratio) as total_coverage
    FROM mimi_ws_1.huduser.zip_to_tract_otm
    GROUP BY zip, usps_zip_pref_city, usps_zip_pref_state
),

density_rankings AS (
    SELECT 
        *,
        -- Rank ZIP codes by residential density
        RANK() OVER (PARTITION BY usps_zip_pref_state ORDER BY avg_res_ratio DESC) as state_density_rank
    FROM residential_density
    WHERE tract_count >= 1  -- Ensure meaningful coverage
)

SELECT 
    zip,
    usps_zip_pref_city,
    usps_zip_pref_state,
    ROUND(avg_res_ratio, 3) as avg_residential_ratio,
    tract_count as census_tract_count,
    ROUND(total_coverage, 2) as coverage_score,
    state_density_rank
FROM density_rankings
WHERE state_density_rank <= 10  -- Top 10 residential areas per state
ORDER BY usps_zip_pref_state, state_density_rank;

/*
How it works:
1. First CTE calculates key residential metrics per ZIP code
2. Second CTE ranks ZIP codes within each state by residential density
3. Final output shows top 10 most residentially dense ZIP codes per state

Assumptions and limitations:
- Assumes residential ratio is the primary indicator of market opportunity
- Limited to areas with at least one census tract mapping
- Does not account for seasonal population variations
- Rankings are relative within each state, not absolute across states

Possible extensions:
1. Add demographic overlay data to understand population characteristics
2. Include business ratio analysis for commercial opportunity assessment
3. Calculate year-over-year changes in residential density
4. Add geographic clustering analysis for market territory planning
5. Incorporate distance calculations to existing service locations
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:48:53.018542
    - Additional Notes: Query provides ZIP-level residential density metrics with state-based rankings. Performance may be impacted when processing states with large numbers of ZIP codes. Consider adding WHERE clauses for specific states or regions if analyzing targeted markets.
    
    */