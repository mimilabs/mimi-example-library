
/* 
Title: Social Deprivation Index (SDI) Analysis by Census Tract

Business Purpose:
This query analyzes the Social Deprivation Index (SDI) distribution across census tracts
to identify areas with high social disadvantage. This information can be used to:
- Target healthcare and social service interventions
- Inform resource allocation decisions
- Monitor health equity across communities
*/

-- Main Query
WITH recent_sdi AS (
  -- Get most recent SDI data year
  SELECT MAX(mimi_src_file_date) as max_date 
  FROM mimi_ws_1.grahamcenter.sdi_censustract
),

sdi_summary AS (
  SELECT 
    -- Extract state FIPS from census tract FIPS
    LEFT(censustract_fips, 2) as state_fips,
    
    -- Calculate key metrics
    COUNT(*) as num_tracts,
    SUM(census_tract_population) as total_population,
    
    -- SDI score statistics 
    AVG(sdi_score) as avg_sdi_score,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY sdi_score) as median_sdi_score,
    
    -- Identify high deprivation tracts
    COUNT(CASE WHEN sdi_score >= 75 THEN 1 END) as high_sdi_tracts,
    SUM(CASE WHEN sdi_score >= 75 THEN census_tract_population ELSE 0 END) as high_sdi_population
    
  FROM mimi_ws_1.grahamcenter.sdi_censustract sdi
  JOIN recent_sdi r
    ON sdi.mimi_src_file_date = r.max_date
  GROUP BY LEFT(censustract_fips, 2)
)

SELECT
  state_fips,
  num_tracts,
  total_population,
  ROUND(avg_sdi_score, 2) as avg_sdi_score,
  ROUND(median_sdi_score, 2) as median_sdi_score,
  high_sdi_tracts,
  -- Calculate percentage of population in high SDI areas
  ROUND(100.0 * high_sdi_population / total_population, 1) as pct_pop_high_sdi
FROM sdi_summary
ORDER BY avg_sdi_score DESC;

/*
How this works:
1. Identifies most recent data year using MAX(mimi_src_file_date)
2. Groups census tracts by state
3. Calculates summary statistics including average/median SDI scores
4. Identifies tracts and population in high deprivation areas (SDI >= 75)
5. Returns ordered results showing states with highest average SDI first

Assumptions & Limitations:
- Uses most recent year of data only
- Defines "high deprivation" as SDI >= 75 (top quartile)
- Aggregates at state level only
- Does not account for variations in tract size/density

Possible Extensions:
1. Add temporal analysis to show SDI trends over time
2. Include component scores (poverty, education etc) in the analysis
3. Add geographic clustering analysis
4. Compare urban vs rural tracts
5. Join with health outcome data to analyze correlations
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:07:29.925366
    - Additional Notes: Query aggregates the latest Social Deprivation Index data at state level, calculating population-weighted metrics and identifying high deprivation areas. Best used for initial state-level health equity assessment and resource allocation planning. Note that the 75th percentile threshold for high deprivation is configurable based on analysis needs.
    
    */