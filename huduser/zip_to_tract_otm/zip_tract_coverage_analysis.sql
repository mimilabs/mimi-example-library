
/* 
ZIP Code to Census Tract Analysis for Geographic Coverage
======================================================

Business Purpose:
This query analyzes the geographic coverage and residential distribution patterns
across ZIP codes and Census tracts to help understand population distribution
and identify key areas for business targeting.

Key business applications:
- Market analysis and targeting
- Service area planning
- Population distribution understanding
- Geographic coverage optimization
*/

-- Main Analysis Query
SELECT 
    z.usps_zip_pref_state as state,
    z.zip,
    z.usps_zip_pref_city as city,
    COUNT(DISTINCT z.tract) as num_census_tracts,
    -- Calculate average residential ratio to understand population distribution
    ROUND(AVG(z.res_ratio),3) as avg_residential_ratio,
    -- Find maximum residential concentration
    ROUND(MAX(z.res_ratio),3) as max_residential_ratio,
    -- Count high-density tracts (>50% residential)
    SUM(CASE WHEN z.res_ratio > 0.5 THEN 1 ELSE 0 END) as high_density_tracts
FROM mimi_ws_1.huduser.zip_to_tract_otm z
GROUP BY 
    z.usps_zip_pref_state,
    z.zip,
    z.usps_zip_pref_city
HAVING num_census_tracts > 1  -- Focus on ZIP codes spanning multiple tracts
ORDER BY 
    num_census_tracts DESC,
    avg_residential_ratio DESC
LIMIT 100;

/*
How It Works:
------------
1. Groups data by state, ZIP code, and city
2. Calculates key metrics for each ZIP code:
   - Number of associated Census tracts
   - Average residential ratio
   - Maximum residential concentration
   - Count of high-density tracts
3. Filters to show only ZIP codes covering multiple tracts
4. Orders by coverage (tract count) and residential density

Assumptions and Limitations:
--------------------------
- Uses latest available mapping data (as of source file date)
- Focuses on residential distribution only
- Assumes current ZIP code boundaries
- Limited to top 100 results for manageability

Possible Extensions:
------------------
1. Add business ratio analysis for commercial area identification
2. Include temporal analysis by incorporating source file dates
3. Join with demographic data for population characteristics
4. Add geographic clustering analysis
5. Include total address count analysis
6. Add filtering by specific states or regions
7. Include year-over-year comparison capabilities
8. Add business vs residential ratio comparison

Sample additional metrics:
- Business to residential ratio comparison
- ZIP code coverage completeness
- Population density estimates
- Service area overlap analysis
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:52:15.608273
    - Additional Notes: Query identifies ZIP codes with complex tract distributions and high residential concentrations. Best used for market analysis and service area planning. Results are limited to top 100 records and focus on multi-tract ZIP codes only. Consider memory usage when removing LIMIT clause for large datasets.
    
    */