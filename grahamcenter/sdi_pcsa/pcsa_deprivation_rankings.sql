
/*******************************************************************************
Title: Social Deprivation Index Analysis by PCSA Region
 
Business Purpose:
This query analyzes the Social Deprivation Index (SDI) and its component scores
across Primary Care Service Areas (PCSAs) to identify regions with high social
deprivation that may need additional healthcare resources and support.

The SDI is a composite measure incorporating factors like poverty, education,
employment and housing conditions that impact healthcare access and outcomes.
*******************************************************************************/

-- Get the latest SDI data and rank PCSAs by overall SDI score
WITH latest_sdi AS (
  SELECT DISTINCT 
    mimi_src_file_date,
    pcsa_fips,
    pcsa_population,
    sdi_score,
    -- Calculate average component scores
    (povertylt100_fpl_score + single_parent_fam_score + 
     education_lt12years_score + hh_no_vehicle_score +
     hh_renter_occupied_score + hh_crowding_score + 
     nonemployed_score) / 7.0 as avg_component_score,
    -- Identify primary contributing factors
    GREATEST(povertylt100_fpl_score, single_parent_fam_score,
            education_lt12years_score, hh_no_vehicle_score,
            hh_renter_occupied_score, hh_crowding_score,
            nonemployed_score) as max_component_score
  FROM mimi_ws_1.grahamcenter.sdi_pcsa
  WHERE mimi_src_file_date = '2019-12-31' -- Using most recent 5-year ACS data
)

SELECT
  pcsa_fips,
  pcsa_population,
  sdi_score,
  avg_component_score,
  max_component_score,
  -- Categorize PCSAs by SDI severity
  CASE 
    WHEN sdi_score >= 75 THEN 'High Deprivation'
    WHEN sdi_score >= 50 THEN 'Moderate Deprivation' 
    ELSE 'Low Deprivation'
  END as deprivation_category,
  -- Calculate percentile rank
  PERCENT_RANK() OVER (ORDER BY sdi_score) as sdi_percentile
FROM latest_sdi
ORDER BY sdi_score DESC
LIMIT 100;

/*******************************************************************************
How this query works:
1. Filters for most recent SDI data (2015-2019 5-year estimates)
2. Calculates average and maximum component scores to identify key drivers
3. Categorizes PCSAs into deprivation levels
4. Ranks PCSAs by SDI score to identify priority areas
5. Returns top 100 highest SDI score areas

Assumptions and Limitations:
- Uses most recent available data (2019)
- Equal weighting of component scores in average calculation
- Arbitrary thresholds for deprivation categories
- Limited to top 100 results
- Does not account for geographic clustering

Possible Extensions:
1. Add geographic grouping (state/region analysis)
2. Compare SDI trends across multiple time periods
3. Correlate with healthcare facility locations
4. Add population-weighted calculations
5. Expand analysis of individual component scores
6. Include geographic clustering analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:41:59.825510
    - Additional Notes: Query focuses on identifying high-priority PCSAs based on social deprivation scores using 2019 data. Component scores are simplified into averages which may mask nuanced patterns. The 75/50 threshold values for categorization are arbitrary and may need adjustment based on specific use cases. Consider local geographic context when interpreting results.
    
    */