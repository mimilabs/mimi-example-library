-- medicare_chronic_care_intensity.sql

-- Purpose: Analyze patterns of chronic disease care delivery and resource utilization
-- across geographic regions to identify variations in care management approaches and
-- opportunities for improving chronic condition outcomes.
-- 
-- Business value:
-- - Identifies regions with higher chronic disease burden and resource needs
-- - Highlights opportunities for care management program interventions  
-- - Enables comparison of care patterns for key chronic conditions
-- - Supports resource allocation and program planning decisions

WITH chronic_metrics AS (
  SELECT 
    year,
    bene_geo_lvl,
    bene_geo_desc,
    bene_geo_cd,
    benes_ffs_cnt,
    bene_avg_risk_scre,
    
    -- Diabetes metrics
    pqi03_dbts_age_65_74 as diabetes_admissions_65_74,
    pqi16_lwrxtrmty_amputn_age_65_74 as diabetes_amputation_65_74,
    
    -- Heart disease metrics  
    pqi08_chf_age_65_74 as heart_failure_admissions_65_74,
    pqi07_hyprtnsn_age_65_74 as hypertension_admissions_65_74,
    
    -- Respiratory metrics
    pqi05_copd_asthma_age_65_74 as copd_admissions_65_74,
    
    -- Cost and utilization context
    tot_mdcr_stdzd_pymt_pc as total_cost_per_capita,
    er_visits_per_1000_benes as er_visits_per_1k,
    
    -- Calculate medians for comparison
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tot_mdcr_stdzd_pymt_pc) 
      OVER () as median_cost_per_capita,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY er_visits_per_1000_benes) 
      OVER () as median_er_visits_per_1k

  FROM mimi_ws_1.datacmsgov.geovariation
  WHERE bene_geo_lvl = 'State'  -- Focus on state-level patterns
    AND year = 2021  -- Most recent complete year
)

SELECT
  bene_geo_desc as state,
  benes_ffs_cnt as beneficiary_count,
  bene_avg_risk_scre as avg_risk_score,
  
  -- Create composite chronic admission rate
  (diabetes_admissions_65_74 + 
   heart_failure_admissions_65_74 + 
   copd_admissions_65_74) as chronic_admission_rate,
   
  -- Calculate ratios relative to national medians
  ROUND(total_cost_per_capita / median_cost_per_capita, 2) as cost_ratio_to_median,
  ROUND(er_visits_per_1k / median_er_visits_per_1k, 2) as er_ratio_to_median

FROM chronic_metrics
ORDER BY chronic_admission_rate DESC;

-- How this works:
-- 1. Creates derived table with key chronic condition metrics at state level
-- 2. Calculates composite chronic admission rate combining major conditions
-- 3. Compares costs and ED use to national medians to provide context
-- 4. Orders results by overall chronic disease burden

-- Assumptions and limitations:
-- - Focuses on 65-74 age group as representative population
-- - Uses admission rates as proxy for condition prevalence/management
-- - Limited to fee-for-service beneficiaries
-- - State-level analysis may mask local variations

-- Possible extensions:
-- 1. Add trending over multiple years to show trajectories
-- 2. Include additional age groups for fuller picture
-- 3. Add demographic factors like dual eligibility rates
-- 4. Calculate condition-specific cost burdens
-- 5. Create risk-adjusted versions of metrics
-- 6. Add quality measures like readmission rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:47:48.302341
    - Additional Notes: Query identifies geographic areas with high chronic disease burden by combining multiple condition-specific admission rates and comparing costs to national medians. Only includes FFS Medicare beneficiaries aged 65-74 and requires 2021 data to be present in the source table. State-level aggregation provides high-level patterns but may not capture local variations.
    
    */