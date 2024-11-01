-- specialty_tier_medicare_plans_analysis.sql

-- Business Purpose: 
-- Analyze Medicare Part D plans' specialty tier structure and coverage
-- This analysis helps:
-- 1. Identify variations in specialty drug coverage across plans
-- 2. Understand specialty tier pricing models
-- 3. Support formulary design decisions and competitive analysis
-- 4. Evaluate beneficiary access to specialty medications

WITH plan_formulary_base AS (
    SELECT 
        bid_id,
        mrx_formulary_tiers_num as total_tiers,
        mrx_form_model_type as formulary_model,
        mrx_drug_ben_yn as offers_drug_benefit,
        mrx_benefit_type as benefit_type,
        mrx_alt_ded_amount as deductible_amount,
        mrx_floor_price_yn as has_floor_pricing,
        mrx_ceiling_price_yn as has_ceiling_pricing,
        mrx_auth_ynba as requires_prior_auth,
        mimi_src_file_date as data_date
    FROM mimi_ws_1.partcd.pbp_mrx
    WHERE mrx_drug_ben_yn = 'Y' -- Only include plans with drug benefits
),

specialty_tier_summary AS (
    SELECT 
        data_date,
        total_tiers,
        COUNT(*) as plan_count,
        AVG(CAST(deductible_amount AS FLOAT)) as avg_deductible,
        SUM(CASE WHEN has_floor_pricing = 'Y' THEN 1 ELSE 0 END) as plans_with_floor_pricing,
        SUM(CASE WHEN has_ceiling_pricing = 'Y' THEN 1 ELSE 0 END) as plans_with_ceiling_pricing,
        SUM(CASE WHEN requires_prior_auth = 'Y' THEN 1 ELSE 0 END) as plans_requiring_auth
    FROM plan_formulary_base
    GROUP BY data_date, total_tiers
)

SELECT 
    data_date,
    total_tiers,
    plan_count,
    ROUND(avg_deductible, 2) as avg_deductible_amount,
    ROUND(100.0 * plans_with_floor_pricing / plan_count, 1) as pct_with_floor_pricing,
    ROUND(100.0 * plans_with_ceiling_pricing / plan_count, 1) as pct_with_ceiling_pricing,
    ROUND(100.0 * plans_requiring_auth / plan_count, 1) as pct_requiring_auth
FROM specialty_tier_summary
WHERE total_tiers >= 5 -- Focus on plans with specialty tiers
ORDER BY data_date DESC, total_tiers;

-- How this works:
-- 1. Creates base table with key plan characteristics
-- 2. Aggregates metrics around specialty tier implementation
-- 3. Calculates percentages of plans with various cost control mechanisms
-- 4. Filters for plans with 5+ tiers (typically including specialty tiers)

-- Assumptions and Limitations:
-- 1. Plans with 5+ tiers are assumed to include specialty tiers
-- 2. Deductible amounts are assumed to be numeric and valid
-- 3. Analysis doesn't capture specific drugs in specialty tiers
-- 4. Time series limited to available data_date values

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare specialty tier features across plan types
-- 3. Analyze correlation between specialty controls and premiums
-- 4. Track changes in specialty tier implementation over time
-- 5. Include specialty drug cost sharing levels
-- 6. Add member impact analysis based on enrollment data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:29:20.198879
    - Additional Notes: Query focuses on cost control mechanisms for specialty tiers and may need adjustment for plans using alternative tier structures. Deductible calculations assume valid numeric values and may require additional data validation for production use. Performance may be impacted with very large datasets due to multiple aggregations.
    
    */