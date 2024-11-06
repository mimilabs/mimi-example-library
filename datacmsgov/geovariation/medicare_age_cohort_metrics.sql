-- medicare_age_cost_quality.sql

-- Purpose: Analyze Medicare cost and quality variations across different age groups 
-- to understand how healthcare needs, spending, and outcomes differ by age cohort.
-- This analysis helps inform age-specific care delivery strategies and resource allocation.

WITH age_groups AS (
  SELECT 
    year,
    bene_geo_desc,
    bene_age_lvl,
    -- Calculate key age-specific metrics
    AVG(tot_mdcr_stdzd_pymt_pc) as avg_standardized_cost_pc,
    AVG(bene_avg_risk_scre) as avg_risk_score,
    AVG(acute_hosp_readmsn_pct) as readmission_rate,
    AVG(er_visits_per_1000_benes) as er_visits_per_1k,
    -- Get beneficiary counts
    SUM(benes_ffs_cnt) as total_benes,
    -- Calculate preventable admission rates by combining key PQIs
    AVG(pqi08_chf_age_lt_65 + pqi08_chf_age_65_74 + pqi08_chf_age_ge_75) as chf_admission_rate,
    AVG(pqi03_dbts_age_lt_65 + pqi03_dbts_age_65_74 + pqi03_dbts_age_ge_75) as diabetes_admission_rate
  FROM mimi_ws_1.datacmsgov.geovariation
  WHERE year >= 2019  -- Focus on recent years
  AND bene_geo_lvl = 'State'  -- State-level analysis
  GROUP BY year, bene_geo_desc, bene_age_lvl
)

SELECT
  year,
  bene_age_lvl,
  -- Calculate national averages per age group
  ROUND(AVG(avg_standardized_cost_pc),2) as national_avg_cost_pc,
  ROUND(AVG(avg_risk_score),3) as national_risk_score,
  ROUND(AVG(readmission_rate),1) as national_readmit_rate,
  ROUND(AVG(er_visits_per_1k),0) as national_er_rate,
  ROUND(AVG(chf_admission_rate),1) as national_chf_rate,
  ROUND(AVG(diabetes_admission_rate),1) as national_diabetes_rate,
  SUM(total_benes) as total_beneficiaries
FROM age_groups
GROUP BY year, bene_age_lvl
ORDER BY year DESC, bene_age_lvl;

-- Query Operation:
-- 1. Creates age group aggregations at state level
-- 2. Calculates key cost and quality metrics per age group
-- 3. Rolls up to national averages while preserving age stratification
-- 4. Presents results in a clear comparative format

-- Assumptions & Limitations:
-- - Uses standardized payments to enable fair geographic comparisons
-- - Focuses on state-level data to balance detail and significance
-- - Combines related PQI measures to create composite admission rates
-- - Limited to FFS Medicare beneficiaries only

-- Possible Extensions:
-- 1. Add trend analysis across multiple years
-- 2. Include demographic breakdowns within age groups
-- 3. Add statistical testing for age group differences
-- 4. Incorporate service-specific utilization patterns by age
-- 5. Create state-level rankings within each age group
-- 6. Add dual-eligible status analysis by age group

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:56:07.817507
    - Additional Notes: Query provides national-level cost and quality metrics stratified by age groups, focusing on recent years (2019+). Results include standardized costs, risk scores, readmission rates, ER utilization, and preventable admissions. The analysis is limited to state-level FFS Medicare data and excludes Medicare Advantage beneficiaries.
    
    */