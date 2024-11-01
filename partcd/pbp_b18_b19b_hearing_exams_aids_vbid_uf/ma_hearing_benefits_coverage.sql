-- Medicare Advantage Hearing Benefits Analysis
-- 
-- Business Purpose: Analyze hearing exam and hearing aid coverage across Medicare Advantage plans
-- to understand benefit design trends and market opportunities in supplemental benefits.
-- This analysis helps identify:
-- - Plans offering competitive hearing benefits
-- - Market gaps in hearing coverage
-- - Potential areas for benefit enhancement

WITH plan_hearing_summary AS (
    -- Get the most recent data for each plan
    SELECT 
        pbp_a_hnumber,
        pbp_a_plan_identifier,
        pbp_a_plan_type,
        -- Hearing exam coverage
        pbp_b18a_bendesc_yn AS offers_hearing_exams,
        pbp_b18a_maxplan_amt AS hearing_exam_max_coverage,
        -- Hearing aid coverage
        pbp_b18b_bendesc_yn AS offers_hearing_aids,
        pbp_b18b_maxplan_amt AS hearing_aid_max_coverage,
        pbp_b18b_otc_yn AS covers_otc_hearing_aids,
        -- Source metadata
        mimi_src_file_date
    FROM mimi_ws_1.partcd.pbp_b18_b19b_hearing_exams_aids_vbid_uf
    WHERE mimi_src_file_date = (
        SELECT MAX(mimi_src_file_date) 
        FROM mimi_ws_1.partcd.pbp_b18_b19b_hearing_exams_aids_vbid_uf
    )
)

SELECT 
    pbp_a_plan_type,
    COUNT(DISTINCT pbp_a_hnumber) as total_contracts,
    -- Hearing exam metrics
    ROUND(AVG(CASE WHEN offers_hearing_exams = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_hearing_exams,
    ROUND(AVG(hearing_exam_max_coverage), 2) as avg_hearing_exam_coverage,
    -- Hearing aid metrics
    ROUND(AVG(CASE WHEN offers_hearing_aids = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_hearing_aids,
    ROUND(AVG(hearing_aid_max_coverage), 2) as avg_hearing_aid_coverage,
    ROUND(AVG(CASE WHEN covers_otc_hearing_aids = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_otc_coverage
FROM plan_hearing_summary
GROUP BY pbp_a_plan_type
ORDER BY total_contracts DESC;

-- How this query works:
-- 1. Creates a CTE with the most recent data for each plan
-- 2. Calculates key metrics around hearing benefit coverage
-- 3. Groups results by plan type to show market segments
--
-- Assumptions and limitations:
-- - Uses most recent data snapshot only
-- - Dollar amounts are assumed to be annual maximums
-- - Does not account for mid-year benefit changes
-- - Averages include only plans with coverage (non-zero amounts)
--
-- Possible extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare benefits year-over-year
-- 3. Include cost-sharing analysis (copays/coinsurance)
-- 4. Add competitor-specific analysis
-- 5. Combine with enrollment data to show member impact

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:42:43.735669
    - Additional Notes: Query aggregates Medicare Advantage hearing benefits at the plan type level, showing coverage rates and average maximum benefits. Results are filtered to most recent data period only. Dollar amounts in results represent maximum plan coverage, not actual spending or utilization.
    
    */