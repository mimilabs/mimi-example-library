-- plan_network_cost_differential.sql

-- Business Purpose:
-- Analyzes cost differentials between preferred and non-preferred pharmacies 
-- to identify potential savings opportunities for beneficiaries and evaluate 
-- plan network strategies. This helps:
-- - Quantify the financial incentives for using preferred pharmacies
-- - Identify plans with significant network cost differentials
-- - Support beneficiary education about pharmacy choice impact
-- - Inform network strategy discussions with health plans

SELECT 
    contract_id,
    plan_id,
    coverage_level,
    tier,
    -- Calculate average cost differential between preferred and non-preferred pharmacies
    AVG(cost_amt_nonpref - cost_amt_pref) as avg_cost_differential,
    -- Calculate percentage cost increase at non-preferred pharmacies
    AVG((cost_amt_nonpref - cost_amt_pref)/NULLIF(cost_amt_pref, 0) * 100) as pct_increase_nonpref,
    -- Count plans with significant differentials
    COUNT(*) as plan_count,
    -- Identify predominant cost type
    MODE(cost_type_pref) as common_cost_type
FROM mimi_ws_1.prescriptiondrugplan.beneficiary_cost
WHERE 
    -- Focus on initial coverage period
    coverage_level = 1
    -- Look at standard 30-day supply
    AND days_supply = 1
    -- Ensure both preferred and non-preferred costs exist
    AND cost_type_pref > 0 
    AND cost_type_nonpref > 0
GROUP BY 
    contract_id,
    plan_id,
    coverage_level,
    tier
HAVING 
    -- Filter for meaningful cost differentials
    AVG(cost_amt_nonpref - cost_amt_pref) > 0
ORDER BY 
    avg_cost_differential DESC
LIMIT 100;

-- Query Operation:
-- 1. Filters for initial coverage period and 30-day supply
-- 2. Calculates absolute and percentage cost differentials
-- 3. Groups by contract/plan/coverage/tier
-- 4. Identifies plans with positive cost differentials
-- 5. Orders by largest cost differential

-- Assumptions and Limitations:
-- - Focuses on initial coverage period only
-- - Assumes 30-day supply as standard comparison
-- - Does not account for mail order options
-- - Cost differentials may vary by region
-- - Some plans may have incomplete data

-- Possible Extensions:
-- 1. Add geographic analysis by joining with plan_information
-- 2. Include mail order comparison
-- 3. Analyze trends over time using mimi_src_file_date
-- 4. Compare differentials across different coverage phases
-- 5. Add specialty tier analysis dimension

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:02:04.011083
    - Additional Notes: Query focuses on quantifying cost differences between preferred and non-preferred pharmacies in the initial coverage period. Results are limited to top 100 plans with highest differentials and require both pharmacy types to have valid cost data. Cost type 1=copay and 2=coinsurance should be interpreted differently when analyzing the differential amounts.
    
    */