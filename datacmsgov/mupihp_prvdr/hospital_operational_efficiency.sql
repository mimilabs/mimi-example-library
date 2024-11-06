-- Medicare Inpatient Hospital Quality and Outcomes Efficiency Analysis

-- Business Purpose:
-- This query analyzes Medicare inpatient hospital effectiveness by examining 
-- the relationships between patient volume, length of stay, and demographics to:
-- 1. Identify hospitals efficiently managing high patient volumes
-- 2. Surface variations in length of stay relative to patient demographics
-- 3. Provide insights for operational and quality improvement initiatives

-- Note: Pulls most recent year's data

WITH base_metrics AS (
  SELECT
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    rndrng_prvdr_ruca_desc,
    
    -- Volume metrics
    tot_dschrgs,
    tot_benes,
    
    -- Efficiency metrics  
    tot_cvrd_days,
    ROUND(tot_cvrd_days::FLOAT/NULLIF(tot_dschrgs,0), 2) as avg_los,
    
    -- Demographics
    bene_avg_age,
    bene_dual_cnt::FLOAT/NULLIF(tot_benes,0) as dual_pct,
    bene_avg_risk_scre
    
  FROM mimi_ws_1.datacmsgov.mupihp_prvdr
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.datacmsgov.mupihp_prvdr)
)

SELECT
  rndrng_prvdr_state_abrvtn as state,
  rndrng_prvdr_ruca_desc as location_type,
  COUNT(DISTINCT rndrng_prvdr_ccn) as hospital_count,
  
  -- Volume metrics
  SUM(tot_dschrgs) as total_discharges,
  ROUND(AVG(tot_dschrgs)) as avg_discharges_per_hospital,
  
  -- Efficiency metrics
  ROUND(AVG(avg_los), 2) as avg_length_of_stay,
  
  -- Patient complexity 
  ROUND(AVG(bene_avg_age), 1) as avg_patient_age,
  ROUND(AVG(dual_pct)*100, 1) as pct_dual_eligible,
  ROUND(AVG(bene_avg_risk_scre), 2) as avg_risk_score

FROM base_metrics
GROUP BY 1, 2
HAVING COUNT(DISTINCT rndrng_prvdr_ccn) >= 3 -- Ensure adequate sample size
ORDER BY total_discharges DESC
LIMIT 20;

-- How this query works:
-- 1. Base metrics CTE calculates key hospital-level metrics
-- 2. Main query aggregates to state/location type level
-- 3. Filters ensure statistical validity
-- 4. Results ordered by total discharge volume

-- Assumptions and limitations:
-- 1. Uses most recent year of data only
-- 2. Requires at least 3 hospitals per group for reporting
-- 3. Does not account for case mix differences
-- 4. Rural/urban classifications may not capture full complexity

-- Possible extensions:
-- 1. Add year-over-year trending
-- 2. Include quality metrics like readmissions
-- 3. Break out by hospital size tiers
-- 4. Add case mix adjustment factors
-- 5. Incorporate specific service line analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:41:37.933667
    - Additional Notes: Query focuses on operational metrics (volume, length of stay) while incorporating demographic and geographic factors to provide insights into hospital efficiency patterns. Results are aggregated at state/location level to identify broader regional trends. Minimum threshold of 3 hospitals per group ensures statistical reliability.
    
    */