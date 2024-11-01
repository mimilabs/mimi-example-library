-- medicare_diabetes_therapy_trends.sql

-- Business Purpose: Analyze patterns in diabetes medication prescribing to:
-- 1. Identify adoption trends of newer diabetes therapies vs traditional medications
-- 2. Support value-based care initiatives by understanding cost and utilization patterns
-- 3. Guide formulary decisions and care management programs for diabetic populations

WITH diabetes_meds AS (
  -- Filter for common diabetes medications and latest year
  SELECT *
  FROM mimi_ws_1.datacmsgov.mupdpr
  WHERE mimi_src_file_date = '2022-12-31'
  AND (
    -- Include major classes of diabetes medications
    LOWER(gnrc_name) LIKE '%metformin%'
    OR LOWER(gnrc_name) LIKE '%glipizide%' 
    OR LOWER(gnrc_name) LIKE '%sitagliptin%'
    OR LOWER(gnrc_name) LIKE '%empagliflozin%'
    OR LOWER(gnrc_name) LIKE '%semaglutide%'
  )
),

prescriber_summary AS (
  -- Calculate key metrics by prescriber and medication
  SELECT 
    prscrbr_state_abrvtn as state,
    gnrc_name,
    brnd_name,
    COUNT(DISTINCT prscrbr_npi) as n_providers,
    SUM(tot_clms) as total_claims,
    SUM(tot_drug_cst) as total_cost,
    ROUND(SUM(tot_drug_cst)/SUM(tot_clms),2) as cost_per_claim
  FROM diabetes_meds
  WHERE prscrbr_state_abrvtn IS NOT NULL
  GROUP BY 1,2,3
)

-- Generate final summary focusing on key diabetes therapy classes
SELECT 
  state,
  gnrc_name,
  brnd_name,
  n_providers,
  total_claims,
  ROUND(total_cost/1000000,2) as total_cost_millions,
  cost_per_claim,
  ROUND(100.0 * total_claims / SUM(total_claims) OVER (PARTITION BY state),1) as pct_state_claims
FROM prescriber_summary
ORDER BY state, total_claims DESC;

-- How this query works:
-- 1. Filters for major diabetes medication classes using generic name patterns
-- 2. Aggregates key utilization and cost metrics by state and medication
-- 3. Calculates relative market share within each state
-- 4. Presents results ordered by state and prescription volume

-- Assumptions and Limitations:
-- 1. Focuses only on select diabetes medications - not comprehensive
-- 2. Uses generic name pattern matching which may miss some medications
-- 3. Limited to Medicare Part D population, not representative of all diabetes care
-- 4. Does not account for combination products or dose variations

-- Possible Extensions:
-- 1. Add year-over-year trending to track adoption of newer agents
-- 2. Include provider specialty analysis to examine prescribing patterns
-- 3. Add patient counts and demographic splits
-- 4. Incorporate more detailed therapeutic classification
-- 5. Compare costs and utilization patterns between similar drug classes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:55:22.607067
    - Additional Notes: Query focuses on geographic variation in diabetes medication usage patterns across states, with emphasis on newer vs traditional therapies in Medicare Part D. Market share calculations enable identification of regional prescribing preferences. Limited to major diabetes drug classes and may need regular updates to medication list as new therapies emerge.
    
    */