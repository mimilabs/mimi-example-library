-- Medicare Part D Plan Structure and Market Segmentation Analysis

-- Business Purpose:
-- This analysis examines how Medicare Part D plans structure their drug tiers and segments
-- to understand market positioning and competitive differentiation strategies.
-- The insights help healthcare organizations identify market opportunities and optimize
-- plan designs to better serve different beneficiary populations.

WITH plan_tiers AS (
    -- Get distinct plan-tier combinations and basic structure
    SELECT DISTINCT
        bid_id,
        pbp_a_plan_type,
        orgtype,
        mrx_tier_id,
        mrx_tier_label_list,
        mrx_tier_drug_type,
        mrx_tier_includes,
        part_d_model_demo,
        part_d_enhncd_cvrg_demo
    FROM mimi_ws_1.partcd.pbp_mrx_tier
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.partcd.pbp_mrx_tier)
),

plan_metrics AS (
    -- Calculate tier metrics by plan
    SELECT 
        bid_id,
        COUNT(DISTINCT mrx_tier_id) as num_tiers,
        COUNT(CASE WHEN LOWER(mrx_tier_drug_type) LIKE '%specialty%' THEN 1 END) as has_specialty_tier,
        COUNT(CASE WHEN LOWER(mrx_tier_drug_type) LIKE '%generic%' THEN 1 END) as num_generic_tiers,
        COUNT(CASE WHEN part_d_model_demo = 'Y' THEN 1 END) as participates_in_demo
    FROM plan_tiers
    GROUP BY bid_id
)

-- Final analysis combining plan structure with market segmentation
SELECT 
    t.pbp_a_plan_type,
    t.orgtype,
    COUNT(DISTINCT t.bid_id) as num_plans,
    AVG(m.num_tiers) as avg_tiers_per_plan,
    SUM(m.has_specialty_tier)/COUNT(DISTINCT t.bid_id) * 100 as pct_with_specialty,
    AVG(m.num_generic_tiers) as avg_generic_tiers,
    SUM(m.participates_in_demo)/COUNT(DISTINCT t.bid_id) * 100 as pct_in_demo_models
FROM plan_tiers t
JOIN plan_metrics m ON t.bid_id = m.bid_id
GROUP BY t.pbp_a_plan_type, t.orgtype
HAVING COUNT(DISTINCT t.bid_id) > 5  -- Filter for significant plan types
ORDER BY num_plans DESC;

-- How this query works:
-- 1. First CTE gets unique plan-tier combinations and key structural elements
-- 2. Second CTE calculates plan-level metrics around tier structure
-- 3. Final query aggregates to show market segmentation by plan type and org type
-- 4. Results show how different plan sponsors structure their offerings

-- Assumptions and Limitations:
-- - Uses most recent data snapshot only
-- - Assumes tier labels and types are consistently coded
-- - Does not account for mid-year plan changes
-- - Focused on structure rather than specific cost sharing amounts

-- Possible Extensions:
-- 1. Add time-series analysis to show evolution of plan structures
-- 2. Include geographic analysis by state/region
-- 3. Correlate tier structures with enrollment data
-- 4. Add cost sharing analysis for key drug categories
-- 5. Compare tier structures between stand-alone PDPs and MA-PDs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:18:59.047632
    - Additional Notes: Query analyzes Medicare Part D plan tier structures across organization types, showing key metrics like average number of tiers, specialty tier adoption, and generic tier coverage. Best used with most recent data snapshot for market segmentation analysis. Performance may be impacted with very large datasets due to multiple aggregations.
    
    */