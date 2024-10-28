
/*******************************************************************************
Title: County-Level Social Deprivation Analysis - Core Business Value Query

Purpose: 
This query analyzes county-level social deprivation patterns using the SDI index
and its component scores. It identifies counties with the highest levels of
social deprivation to help target interventions and resource allocation.

Business Value:
- Identifies areas of greatest social need for public health initiatives
- Enables data-driven resource allocation decisions
- Supports health equity analysis and planning
*******************************************************************************/

WITH ranked_counties AS (
  SELECT 
    county_fips,
    county_population,
    sdi_score,
    -- Calculate percentile ranks
    PERCENT_RANK() OVER (ORDER BY sdi_score) as sdi_percentile,
    -- Calculate component score averages
    (povertylt100_fpl_score + single_parent_fam_score + 
     education_lt12years_score + hh_no_vehicle_score +
     hh_renter_occupied_score + hh_crowding_score + 
     nonemployed_score) / 7.0 as avg_component_score
  FROM mimi_ws_1.grahamcenter.sdi_county
  -- Filter to most recent data
  WHERE mimi_src_file_date = '2019-12-31'
)

SELECT
  county_fips,
  county_population,
  sdi_score,
  ROUND(sdi_percentile * 100, 1) as sdi_percentile,
  ROUND(avg_component_score, 1) as avg_component_score,
  -- Categorize deprivation level
  CASE 
    WHEN sdi_percentile >= 0.9 THEN 'Very High'
    WHEN sdi_percentile >= 0.75 THEN 'High'
    WHEN sdi_percentile >= 0.25 THEN 'Moderate'
    ELSE 'Low'
  END as deprivation_level
FROM ranked_counties
-- Focus on counties with significant deprivation
WHERE sdi_percentile >= 0.75
ORDER BY sdi_score DESC
LIMIT 100;

/*******************************************************************************
How It Works:
1. Uses CTE to calculate percentile ranks and average component scores
2. Filters for most recent data (2019)
3. Categorizes counties into deprivation levels
4. Returns top 100 most deprived counties

Assumptions & Limitations:
- Uses 2019 data only - may need updating for more recent periods
- Equal weighting of component scores in average calculation
- County-level analysis may mask neighborhood-level variations
- Limited to top 100 counties for manageable analysis

Possible Extensions:
1. Add geographic grouping (state-level aggregation)
2. Include year-over-year trend analysis
3. Correlate with health outcome data
4. Add demographic breakdowns
5. Compare with other social vulnerability indices
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:05:01.923493
    - Additional Notes: Query focuses on counties with high social deprivation (top 25th percentile) using 2019 data. The average component score calculation assumes equal weighting of factors, which may not reflect their true relative importance in social deprivation. Population size should be considered when interpreting results as smaller counties may show more extreme scores.
    
    */