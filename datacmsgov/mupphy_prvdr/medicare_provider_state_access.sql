-- medicare_provider_demographics_by_state.sql

-- Business Purpose:
-- Analyze the geographic distribution and demographic characteristics of Medicare providers
-- to identify potential access gaps and understand provider workforce demographics.
-- This analysis helps inform provider recruitment, network planning, and diversity initiatives.

-- Get provider counts and demographic breakdowns by state
WITH provider_state_summary AS (
  SELECT 
    rndrng_prvdr_state_abrvtn as state,
    COUNT(DISTINCT rndrng_npi) as total_providers,
    
    -- Calculate provider type breakdowns
    SUM(CASE WHEN rndrng_prvdr_ent_cd = 'I' THEN 1 ELSE 0 END) as individual_providers,
    SUM(CASE WHEN rndrng_prvdr_ent_cd = 'O' THEN 1 ELSE 0 END) as org_providers,
    
    -- Calculate gender distribution for individual providers
    SUM(CASE WHEN rndrng_prvdr_gndr = 'F' THEN 1 ELSE 0 END) as female_providers,
    SUM(CASE WHEN rndrng_prvdr_gndr = 'M' THEN 1 ELSE 0 END) as male_providers,
    
    -- Calculate urban/rural distribution
    COUNT(CASE WHEN rndrng_prvdr_ruca_desc LIKE '%Urban%' THEN 1 END) as urban_providers,
    COUNT(CASE WHEN rndrng_prvdr_ruca_desc LIKE '%Rural%' THEN 1 END) as rural_providers,
    
    -- Calculate average beneficiary metrics
    ROUND(AVG(tot_benes), 0) as avg_beneficiaries_per_provider,
    ROUND(AVG(bene_avg_risk_scre), 2) as avg_risk_score
  FROM mimi_ws_1.datacmsgov.mupphy_prvdr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
    AND rndrng_prvdr_state_abrvtn IS NOT NULL
    AND rndrng_prvdr_state_abrvtn != 'ZZ' -- Exclude non-US locations
  GROUP BY 1
)

SELECT 
  state,
  total_providers,
  individual_providers,
  org_providers,
  female_providers,
  male_providers,
  urban_providers,
  rural_providers,
  avg_beneficiaries_per_provider,
  avg_risk_score,
  -- Calculate key percentages
  ROUND(100.0 * female_providers / NULLIF(individual_providers, 0), 1) as pct_female,
  ROUND(100.0 * rural_providers / NULLIF(total_providers, 0), 1) as pct_rural
FROM provider_state_summary
ORDER BY total_providers DESC;

-- How this query works:
-- 1. Creates a CTE that aggregates provider metrics by state
-- 2. Calculates counts of different provider types and characteristics
-- 3. Computes average beneficiary metrics per state
-- 4. Returns final summary with calculated percentages
-- 5. Orders results by total provider count

-- Assumptions and Limitations:
-- - Uses most recent full year of data (2022)
-- - Excludes providers with missing state info or international locations
-- - Gender analysis limited to individual providers (not organizations)
-- - Urban/rural classification based on RUCA codes
-- - Some states may have small sample sizes affecting percentage calculations

-- Possible Extensions:
-- 1. Add year-over-year trending
-- 2. Include specialty distribution analysis
-- 3. Add Medicare participation rate analysis
-- 4. Compare provider demographics to beneficiary demographics
-- 5. Add geographic analysis at county or ZIP level
-- 6. Include cost and utilization metrics by provider demographics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:20:19.660814
    - Additional Notes: Query focuses on provider distribution and access metrics across states, particularly useful for network adequacy planning. Limited to individual provider demographics (gender analysis may exclude organizational providers) and assumes complete state location data. Risk scores and beneficiary counts provide additional context for access analysis.
    
    */