-- pcsa_sdi_correlation_analysis.sql
-- Business Purpose: Analyze the relationships between different social deprivation factors
-- within Primary Care Service Areas (PCSAs) to understand which factors tend to cluster together.
-- This insight helps healthcare organizations and policymakers develop more targeted
-- interventions by identifying common patterns of social needs.

WITH normalized_scores AS (
  -- Select most recent data and normalize scores to 0-1 scale
  SELECT 
    pcsa_fips,
    pcsa_population,
    sdi_score/100 as sdi_norm,
    povertylt100_fpl_score/100 as poverty_norm,
    single_parent_fam_score/100 as single_parent_norm, 
    education_lt12years_score/100 as education_norm,
    hh_no_vehicle_score/100 as no_vehicle_norm,
    hh_renter_occupied_score/100 as renter_norm,
    hh_crowding_score/100 as crowding_norm,
    nonemployed_score/100 as nonemployed_norm
  FROM mimi_ws_1.grahamcenter.sdi_pcsa
  WHERE mimi_src_file_date = '2019-12-31'
),

correlations AS (
  -- Calculate correlation coefficients between SDI and component scores
  SELECT
    corr(sdi_norm, poverty_norm) as poverty_correlation,
    corr(sdi_norm, single_parent_norm) as single_parent_correlation,
    corr(sdi_norm, education_norm) as education_correlation,
    corr(sdi_norm, no_vehicle_norm) as no_vehicle_correlation,
    corr(sdi_norm, renter_norm) as renter_correlation,
    corr(sdi_norm, crowding_norm) as crowding_correlation,
    corr(sdi_norm, nonemployed_norm) as nonemployed_correlation
  FROM normalized_scores
)

-- Present results with meaningful labels and rounded values
SELECT 
  'Poverty' as factor,
  ROUND(poverty_correlation, 3) as correlation_with_sdi
FROM correlations
UNION ALL
SELECT 'Single Parent Families', ROUND(single_parent_correlation, 3)
FROM correlations
UNION ALL
SELECT 'Education < 12 Years', ROUND(education_correlation, 3)
FROM correlations
UNION ALL
SELECT 'No Vehicle Access', ROUND(no_vehicle_correlation, 3)
FROM correlations
UNION ALL
SELECT 'Renter Occupied Housing', ROUND(renter_correlation, 3)
FROM correlations
UNION ALL
SELECT 'Household Crowding', ROUND(crowding_correlation, 3)
FROM correlations
UNION ALL
SELECT 'Non-employed Status', ROUND(nonemployed_correlation, 3)
FROM correlations
ORDER BY correlation_with_sdi DESC;

-- How it works:
-- 1. Normalizes all scores to 0-1 scale for consistent comparison
-- 2. Calculates correlation coefficients between overall SDI and each component
-- 3. Presents results in ranked order to show which factors have strongest relationship with overall deprivation

-- Assumptions and limitations:
-- - Uses most recent data (2019) only
-- - Assumes linear relationships between variables
-- - Does not account for geographic clustering or spatial relationships
-- - Correlation does not imply causation

-- Possible extensions:
-- 1. Add year-over-year correlation trend analysis
-- 2. Include geographic groupings (state/region) to see if patterns vary by location
-- 3. Add population-weighted correlation calculations
-- 4. Expand to include cross-correlations between individual components
-- 5. Add statistical significance testing for correlations
-- 6. Create correlation heat map visualization using BI tools

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:34:42.931836
    - Additional Notes: The script provides correlation analysis between SDI scores and contributing factors. It only uses the most recent data point (2019) and assumes linear relationships between variables. Results are normalized and rounded to 3 decimal places for clarity. Consider population weighting for more accurate regional analysis.
    
    */