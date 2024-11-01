-- mail_order_incentive_analysis.sql
-- Business Purpose: Analyze mail order pharmacy cost incentives across Medicare Part D plans
-- to identify savings opportunities and evaluate plan strategies for promoting mail order utilization.
-- This helps:
-- - Identify plans with strongest mail order incentives
-- - Evaluate potential beneficiary savings from mail order
-- - Understand mail order adoption strategies
-- - Support decisions about pharmacy channel strategy

SELECT 
    contract_id,
    plan_id,
    -- Focus on 90-day supply to compare retail vs mail order
    COUNT(CASE WHEN days_supply = 2 THEN 1 END) as plans_with_90day,
    
    -- Calculate average cost differential between retail and mail for 90-day
    AVG(CASE 
        WHEN days_supply = 2 AND cost_type_nonpref = 1 AND cost_type_mail_pref = 1
        THEN cost_amt_nonpref - cost_amt_mail_pref 
        END) as avg_copay_savings_mail,
    
    -- Identify % of tiers with mail order savings
    AVG(CASE 
        WHEN days_supply = 2 AND cost_amt_mail_pref < cost_amt_nonpref 
        THEN 1 ELSE 0 
        END) * 100 as pct_tiers_with_mail_savings,
    
    -- Flag plans with consistent mail order incentives
    CASE WHEN MIN(CASE 
        WHEN days_supply = 2 
        THEN (CASE WHEN cost_amt_mail_pref < cost_amt_nonpref THEN 1 ELSE 0 END)
        END) = 1 THEN 'Yes' ELSE 'No' 
        END as consistent_mail_incentives,
        
    -- Count tiers with mail order option
    COUNT(CASE WHEN cost_type_mail_pref > 0 THEN 1 END) as tiers_with_mail_option

FROM mimi_ws_1.prescriptiondrugplan.beneficiary_cost
WHERE coverage_level = 1  -- Focus on initial coverage period
GROUP BY contract_id, plan_id
HAVING COUNT(CASE WHEN days_supply = 2 THEN 1 END) > 0  -- Only plans with 90-day options
ORDER BY avg_copay_savings_mail DESC
LIMIT 100;

-- How it works:
-- 1. Filters to initial coverage period and groups by plan
-- 2. Calculates various mail order incentive metrics
-- 3. Focuses on 90-day supply for direct comparison
-- 4. Identifies plans with strongest mail order incentives

-- Assumptions & Limitations:
-- - Focuses only on initial coverage period
-- - Compares preferred mail order to non-preferred retail
-- - Limited to copay comparisons where both amounts are available
-- - Does not account for drug-specific variations

-- Possible Extensions:
-- 1. Add geographic analysis to identify regional variations
-- 2. Include trend analysis across multiple quarters
-- 3. Incorporate specialty drug tier analysis
-- 4. Add correlation with plan star ratings
-- 5. Compare mail order incentives between PDP and MA-PD plans
-- 6. Analyze relationship between mail incentives and premium levels

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:06:30.235573
    - Additional Notes: Query focuses on direct cost comparisons between retail and mail order pharmacies for 90-day supplies during initial coverage period. Results are limited to top 100 plans with strongest mail order incentives. Cost differentials are calculated only where both mail order and retail options exist with comparable cost types.
    
    */