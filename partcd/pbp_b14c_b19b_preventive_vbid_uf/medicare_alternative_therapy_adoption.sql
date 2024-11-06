-- medicare_alternative_therapy_coverage.sql
-- Business Purpose: Analyze Medicare Advantage plans' coverage of alternative therapies 
-- and therapeutic massage to understand market penetration and cost-sharing structures.
-- This insight helps identify market opportunities and competitive positioning.

WITH alternative_therapy_plans AS (
    -- Get plans offering alternative therapy or therapeutic massage
    SELECT 
        pbp_a_hnumber,
        pbp_a_plan_identifier,
        segment_id,
        pbp_a_plan_type,
        pbp_b14c_bendesc_amo_at AS alt_therapy_benefit_type,
        pbp_b14c_bendesc_lim_at AS alt_therapy_unlimited,
        pbp_b14c_at_visits AS alt_therapy_visits,
        pbp_b14c_bendesc_thp_msg AS therapeutic_massage_type,
        pbp_b14c_thp_msg_unlimited AS massage_unlimited,
        pbp_b14c_thp_msg_num_amt AS massage_sessions,
        pbp_b14c_maxplan_amt_at AS alt_therapy_max_coverage,
        pbp_b14c_maxplan_amt_thms AS massage_max_coverage
    FROM mimi_ws_1.partcd.pbp_b14c_b19b_preventive_vbid_uf
    WHERE pbp_b14c_bendesc_amo_at IS NOT NULL 
    OR pbp_b14c_bendesc_thp_msg IS NOT NULL
)

SELECT 
    pbp_a_plan_type,
    COUNT(DISTINCT pbp_a_hnumber) as contract_count,
    -- Alternative therapy metrics
    COUNT(CASE WHEN alt_therapy_benefit_type IS NOT NULL THEN 1 END) as alt_therapy_plans,
    AVG(CASE WHEN alt_therapy_unlimited = 'Y' THEN 1 ELSE 0 END) as pct_unlimited_alt_therapy,
    AVG(CAST(alt_therapy_visits AS INT)) as avg_annual_visits,
    AVG(CAST(alt_therapy_max_coverage AS INT)) as avg_max_coverage,
    -- Therapeutic massage metrics
    COUNT(CASE WHEN therapeutic_massage_type IS NOT NULL THEN 1 END) as massage_plans,
    AVG(CASE WHEN massage_unlimited = 'Y' THEN 1 ELSE 0 END) as pct_unlimited_massage,
    AVG(CAST(massage_sessions AS INT)) as avg_massage_sessions,
    AVG(CAST(massage_max_coverage AS INT)) as avg_massage_max_coverage
FROM alternative_therapy_plans
GROUP BY pbp_a_plan_type
HAVING contract_count > 5  -- Filter out rare plan types
ORDER BY contract_count DESC;

-- How it works:
-- 1. CTE identifies plans offering alternative therapy or therapeutic massage
-- 2. Main query aggregates by plan type to show coverage patterns
-- 3. Calculates key metrics for both alternative therapy and massage benefits
-- 4. Filters small plan types to focus on significant market segments

-- Assumptions & Limitations:
-- - Assumes NULL values indicate no coverage rather than missing data
-- - Dollar amounts may need inflation adjustment for trend analysis
-- - Does not account for geographic variations
-- - Plan participation may vary throughout the year

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare cost sharing approaches (copay vs coinsurance)
-- 3. Trend analysis across multiple years
-- 4. Correlation with plan star ratings or enrollment numbers
-- 5. Analysis of combined benefits with chiropractic/acupuncture

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:05:35.817878
    - Additional Notes: Query focuses on market penetration analysis of alternative therapy benefits, including visit limits and coverage maximums. Best used with recent data as benefit structures may have changed significantly over time. Results exclude plan types with fewer than 5 contracts to ensure statistical relevance.
    
    */