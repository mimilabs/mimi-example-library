-- nhanes_iron_nutritional_status.sql

-- Business Purpose:
-- - Assess population iron status and potential deficiency patterns
-- - Support public health nutrition programs and interventions
-- - Enable evidence-based screening for anemia risk
-- - Identify demographic groups that may need targeted iron supplementation

WITH iron_metrics AS (
  SELECT
    seqn,
    -- Convert iron measurements to consistent units
    lbxsir1 as iron_ug_dl,
    lbdsirsi1 as iron_umol_l,
    -- Include related proteins that affect iron metabolism
    lbxsal1 as albumin_g_dl,
    lbxstp as total_protein_g_dl,
    -- Track data source
    mimi_src_file_date,
    mimi_src_file_name
  FROM mimi_ws_1.cdc.nhanes_lab_standard_biochemistry_profile
  WHERE lbxsir1 IS NOT NULL
)

SELECT
  -- Calculate summary statistics for iron levels
  COUNT(*) as total_samples,
  
  -- Iron measurements in ug/dL
  ROUND(AVG(iron_ug_dl),1) as avg_iron_ug_dl,
  ROUND(PERCENTILE(iron_ug_dl, 0.25),1) as p25_iron_ug_dl,
  ROUND(PERCENTILE(iron_ug_dl, 0.5),1) as median_iron_ug_dl,
  ROUND(PERCENTILE(iron_ug_dl, 0.75),1) as p75_iron_ug_dl,
  
  -- Calculate potential iron deficiency prevalence
  -- Using common clinical threshold of <50 ug/dL
  ROUND(100.0 * SUM(CASE WHEN iron_ug_dl < 50 THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_low_iron,
  
  -- Distribution of albumin levels for context
  ROUND(AVG(albumin_g_dl),1) as avg_albumin_g_dl,
  
  -- Track data vintage
  MIN(mimi_src_file_date) as earliest_data,
  MAX(mimi_src_file_date) as latest_data
  
FROM iron_metrics

-- How this query works:
-- 1. Creates CTE to extract and standardize iron measurements
-- 2. Calculates population-level statistics and deficiency prevalence
-- 3. Includes related proteins to provide context for iron binding/transport
-- 4. Tracks data sources and timeframes

-- Assumptions and limitations:
-- - Uses simplified clinical thresholds that may need adjustment
-- - Does not account for demographic variations
-- - Cannot determine causality of low iron status
-- - Point measurements may not reflect long-term status

-- Possible extensions:
-- 1. Add demographic stratification (age, sex, race/ethnicity)
-- 2. Include seasonal analysis of iron status
-- 3. Correlate with dietary intake data if available
-- 4. Add additional iron binding proteins and markers
-- 5. Compare against international reference ranges
-- 6. Add trends analysis across survey cycles

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:26:58.007867
    - Additional Notes: Query provides population-level iron status metrics using NHANES biochemistry data, focusing on clinical thresholds for iron deficiency. Best used for initial public health screening assessments rather than individual diagnosis. Consider local reference ranges when adapting thresholds.
    
    */