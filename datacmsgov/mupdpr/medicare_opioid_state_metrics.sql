-- medicare_opioid_prescribing_analysis.sql

-- Business Purpose: Analyze opioid prescribing patterns across geographic regions to:
-- 1. Monitor opioid prescription volume and costs by state
-- 2. Support public health interventions and prescription monitoring programs
-- 3. Identify geographic areas that may need additional oversight or resources
-- 4. Help payers and regulators develop targeted intervention strategies

WITH opioid_prescriptions AS (
  -- Filter for common opioid medications and most recent year
  SELECT 
    prscrbr_state_abrvtn,
    gnrc_name,
    COUNT(DISTINCT prscrbr_npi) as prescriber_count,
    SUM(tot_clms) as total_claims,
    SUM(tot_benes) as total_beneficiaries,
    SUM(tot_drug_cst) as total_cost,
    ROUND(SUM(tot_drug_cst)/SUM(tot_clms), 2) as cost_per_claim
  FROM mimi_ws_1.datacmsgov.mupdpr
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
  AND LOWER(gnrc_name) LIKE ANY (
    '%hydrocodone%',
    '%oxycodone%',
    '%morphine%',
    '%fentanyl%',
    '%tramadol%'
  )
  GROUP BY prscrbr_state_abrvtn, gnrc_name
)

SELECT 
  prscrbr_state_abrvtn as state,
  SUM(total_claims) as state_opioid_claims,
  SUM(total_beneficiaries) as state_opioid_beneficiaries,
  ROUND(SUM(total_cost)/1000000, 2) as state_opioid_cost_millions,
  ROUND(AVG(cost_per_claim), 2) as avg_cost_per_claim,
  SUM(prescriber_count) as total_opioid_prescribers
FROM opioid_prescriptions
GROUP BY prscrbr_state_abrvtn
ORDER BY state_opioid_claims DESC;

-- How it works:
-- 1. CTE filters for major opioid medications and calculates key metrics by state and drug
-- 2. Main query aggregates to state level for high-level geographic analysis
-- 3. Results show total claims, beneficiaries, costs and prescribers by state
-- 4. Cost per claim calculation helps identify cost efficiency opportunities

-- Assumptions & Limitations:
-- 1. Limited to specific opioid generic names - may miss some less common opioids
-- 2. Suppressed values (counts <11) may affect totals
-- 3. State-level analysis may mask important local variations
-- 4. Does not account for patient risk factors or medical necessity

-- Possible Extensions:
-- 1. Add time-series analysis to track trends
-- 2. Include provider specialty analysis
-- 3. Calculate morphine milligram equivalents (MME)
-- 4. Compare to state population data for per-capita analysis
-- 5. Add benchmarking against national averages
-- 6. Include analysis of concurrent benzodiazepine prescriptions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:19:44.633871
    - Additional Notes: Query focuses on five major opioid categories and provides state-level aggregation of key prescription metrics. Results are limited to 2022 data and may be affected by data suppression rules for low counts. Consider local regulations and privacy requirements when sharing results.
    
    */