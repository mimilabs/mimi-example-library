-- Medicare Hospital Utilization and Care Intensity Analysis

-- Business Purpose: This query analyzes hospital utilization patterns among Medicare beneficiaries to:
-- 1. Identify populations with high healthcare resource needs
-- 2. Support care management program planning and resource allocation
-- 3. Guide interventions to reduce potentially preventable hospitalizations
-- 4. Understand relationships between health status and hospital use

WITH hospital_metrics AS (
  SELECT
    -- Demographic grouping
    pufs006 as race_ethnicity,
    pufs013 as health_status,
    pufs011 as census_region,
    
    -- Calculate hospital utilization metrics
    COUNT(*) as beneficiary_count,
    AVG(CAST(pufs031 as FLOAT)) as avg_hospital_stays,
    SUM(CASE WHEN pufs031 > 2 THEN 1 ELSE 0 END) as high_utilizer_count,
    
    -- Calculate related health factors
    AVG(CAST(pufs026 as FLOAT)) as avg_chronic_conditions,
    SUM(CASE WHEN pufs026 >= 3 THEN 1 ELSE 0 END) as multiple_conditions_count
    
  FROM mimi_ws_1.datacmsgov.mcbs_summer
  WHERE surveyyr = 2021  -- Focus on most recent year
    AND pufs031 IS NOT NULL
  GROUP BY 
    pufs006,
    pufs013,
    pufs011
)

SELECT
  race_ethnicity,
  health_status,
  census_region,
  beneficiary_count,
  ROUND(avg_hospital_stays, 2) as avg_stays_per_year,
  ROUND(100.0 * high_utilizer_count / beneficiary_count, 1) as pct_high_utilizers,
  ROUND(avg_chronic_conditions, 1) as avg_conditions,
  ROUND(100.0 * multiple_conditions_count / beneficiary_count, 1) as pct_multiple_conditions
FROM hospital_metrics
WHERE beneficiary_count >= 100  -- Ensure statistical reliability
ORDER BY avg_hospital_stays DESC
LIMIT 20;

-- How this works:
-- 1. Creates temp table with aggregated metrics by demographic groups
-- 2. Calculates key utilization and health status indicators
-- 3. Filters for statistical reliability and ranks by hospital use

-- Assumptions and Limitations:
-- - Relies on self-reported hospital stays data
-- - May not capture all types of facility stays
-- - Geographic analysis limited to census regions
-- - Single year snapshot rather than longitudinal trends

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include emergency department utilization metrics
-- 3. Analyze relationship with functional limitations (ADL/IADL)
-- 4. Incorporate cost and coverage type analysis
-- 5. Add seasonal variation analysis
-- 6. Include social determinants of health factors

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:46:22.450167
    - Additional Notes: Query filters for minimum 100 beneficiaries per group to ensure statistical validity. Hospital stay counts are from self-reported data (pufs031) and may undercount total healthcare facility usage. Census region grouping provides broad geographic trends but masks local variation.
    
    */