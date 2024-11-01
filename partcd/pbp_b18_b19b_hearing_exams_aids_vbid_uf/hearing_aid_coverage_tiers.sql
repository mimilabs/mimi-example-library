-- medicare_hearing_aid_max_coverage_analysis.sql --

-- Business Purpose:
-- Analyze Medicare Advantage plan maximum coverage amounts for hearing aids
-- to identify market opportunities and competitive positioning for hearing aid benefits.
-- This analysis helps understand price points and coverage periods that plans are offering,
-- which is valuable for benefit design and market strategy.

WITH hearing_aid_coverage AS (
    -- Get latest data per contract/plan/segment
    SELECT 
        pbp_a_hnumber,
        pbp_a_plan_identifier,
        segment_id,
        pbp_b18b_bendesc_yn AS offers_hearing_aids,
        pbp_b18b_maxplan_amt AS max_coverage_amount,
        pbp_b18b_maxplan_per AS coverage_period,
        pbp_b18b_maxplan_perear AS per_ear_coverage,
        mimi_src_file_date
    FROM mimi_ws_1.partcd.pbp_b18_b19b_hearing_exams_aids_vbid_uf
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY pbp_a_hnumber, pbp_a_plan_identifier, segment_id 
        ORDER BY mimi_src_file_date DESC
    ) = 1
)

-- Analyze distribution of maximum coverage amounts
SELECT 
    CASE 
        WHEN max_coverage_amount IS NULL THEN 'No Coverage Limit'
        WHEN max_coverage_amount = 0 THEN 'No Coverage'
        WHEN max_coverage_amount <= 1000 THEN '$1-$1000'
        WHEN max_coverage_amount <= 2000 THEN '$1001-$2000'
        WHEN max_coverage_amount <= 3000 THEN '$2001-$3000'
        WHEN max_coverage_amount > 3000 THEN 'Over $3000'
    END AS coverage_tier,
    coverage_period,
    COUNT(*) AS plan_count,
    ROUND(AVG(max_coverage_amount), 2) AS avg_coverage_amount,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_total_plans
FROM hearing_aid_coverage
WHERE offers_hearing_aids = 'Y'
GROUP BY 1, 2
ORDER BY 
    coverage_period,
    CASE coverage_tier
        WHEN 'No Coverage' THEN 1
        WHEN '$1-$1000' THEN 2
        WHEN '$1001-$2000' THEN 3
        WHEN '$2001-$3000' THEN 4
        WHEN 'Over $3000' THEN 5
        WHEN 'No Coverage Limit' THEN 6
    END;

-- How this query works:
-- 1. Creates a CTE to get the latest data for each plan
-- 2. Categorizes plans by coverage amount tiers
-- 3. Aggregates plans by coverage tier and period
-- 4. Calculates key metrics including plan count and percentage distribution

-- Assumptions and Limitations:
-- - Uses most recent data point for each plan
-- - Assumes coverage amounts are annual unless specified otherwise
-- - Does not account for network distinctions
-- - Focuses only on plans that offer hearing aid coverage

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare coverage trends year over year
-- 3. Include analysis of per-ear vs total coverage differences
-- 4. Add correlation with plan star ratings
-- 5. Include cost sharing analysis (copays/coinsurance)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:10:07.675212
    - Additional Notes: Query segments Medicare Advantage hearing aid benefits by coverage amount tiers and analyzes distribution patterns. Only considers plans actively offering hearing aid coverage. Coverage amounts are assumed to be in USD and periods are standardized across plans.
    
    */