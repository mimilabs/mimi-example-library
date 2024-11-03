-- medicare_care_transitions_analysis.sql 
--
-- Purpose: Analyze patterns of care transitions and post-acute care utilization across geographic regions
-- to identify opportunities for improving care coordination and reducing readmissions.
--
-- Business value: 
-- - Identifies regions with higher readmission rates and post-acute care usage patterns
-- - Helps target care coordination and transition programs 
-- - Supports network optimization for post-acute partnerships
-- - Informs value-based care strategies

WITH post_acute_metrics AS (
  SELECT
    year,
    bene_geo_lvl,
    bene_geo_desc,
    bene_geo_cd,
    
    -- Overall readmission metrics
    acute_hosp_readmsn_cnt,
    acute_hosp_readmsn_pct,
    
    -- SNF utilization 
    benes_snf_pct,
    snf_cvrd_stays_per_1000_benes,
    snf_mdcr_stdzd_pymt_pc,
    
    -- Home health utilization
    benes_hh_pct, 
    hh_episodes_per_1000_benes,
    hh_mdcr_stdzd_pymt_pc,
    
    -- IRF utilization
    benes_irf_pct,
    irf_cvrd_stays_per_1000_benes,
    irf_mdcr_stdzd_pymt_pc
    
  FROM mimi_ws_1.datacmsgov.geovariation
  WHERE year = 2022  -- Most recent year
    AND bene_geo_lvl = 'State' -- State-level analysis
)

SELECT
  bene_geo_desc as state,
  
  -- Readmission metrics
  acute_hosp_readmsn_pct as readmit_rate,
  
  -- Post-acute utilization rates
  benes_snf_pct as snf_util_pct,
  benes_hh_pct as hh_util_pct,
  benes_irf_pct as irf_util_pct,
  
  -- Post-acute episodes per 1000
  snf_cvrd_stays_per_1000_benes as snf_stays_per_1k,
  hh_episodes_per_1000_benes as hh_episodes_per_1k,
  irf_cvrd_stays_per_1000_benes as irf_stays_per_1k,
  
  -- Post-acute spending per capita
  snf_mdcr_stdzd_pymt_pc as snf_spend_pc,
  hh_mdcr_stdzd_pymt_pc as hh_spend_pc,
  irf_mdcr_stdzd_pymt_pc as irf_spend_pc

FROM post_acute_metrics
ORDER BY acute_hosp_readmsn_pct DESC;

-- How this works:
-- 1. Creates CTE to gather key post-acute metrics at state level
-- 2. Selects readmission rates and utilization/spending metrics for each post-acute setting
-- 3. Orders results by readmission rate to highlight highest opportunity states
--
-- Assumptions & Limitations:
-- - Uses most recent year of data only (2022)
-- - State-level analysis only - loses local market variation
-- - Does not account for patient risk factors or social determinants
-- - Limited to fee-for-service Medicare beneficiaries
--
-- Possible extensions:
-- 1. Add year-over-year trending
-- 2. Include county-level analysis for target markets
-- 3. Add demographic and social determinant factors
-- 4. Compare utilization patterns by facility type
-- 5. Add cost-per-episode metrics
-- 6. Correlate with quality measures
-- 7. Segment by major diagnostic categories
-- 8. Calculate transition patterns between settings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:00:48.358679
    - Additional Notes: Query focuses on three key post-acute settings (SNF, Home Health, IRF) and readmission patterns. The state-level aggregation may mask important local market variations. Consider running at county level for specific market analysis. Cost metrics are standardized to remove geographic payment differences.
    
    */