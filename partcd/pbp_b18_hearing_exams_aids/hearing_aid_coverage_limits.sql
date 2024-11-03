-- medicare_advantage_hearing_aid_limit_analysis.sql
--
-- Business Purpose:
-- Analyze maximum plan coverage limits and periodicity for hearing aids 
-- to understand benefit design patterns and identify potential gaps in coverage.
-- This helps insurance companies and providers optimize their hearing aid benefit offerings
-- and identify market opportunities.

WITH coverage_summary AS (
    SELECT 
        -- Identify unique plans
        pbp_a_hnumber,
        pbp_a_plan_identifier,
        pbp_a_plan_type,
        
        -- Analyze coverage patterns
        COUNT(*) as total_plans,
        
        -- Maximum benefit amounts
        AVG(CAST(pbp_b18b_maxplan_amt AS FLOAT)) as avg_max_coverage_amount,
        MAX(CAST(pbp_b18b_maxplan_amt AS FLOAT)) as highest_coverage_amount,
        
        -- Coverage period distribution
        SUM(CASE WHEN pbp_b18b_maxplan_per = '1' THEN 1 ELSE 0 END) as yearly_coverage_count,
        SUM(CASE WHEN pbp_b18b_maxplan_per = '2' THEN 1 ELSE 0 END) as two_year_coverage_count,
        SUM(CASE WHEN pbp_b18b_maxplan_per = '3' THEN 1 ELSE 0 END) as three_year_coverage_count,
        
        -- Per ear vs combined coverage
        SUM(CASE WHEN pbp_b18b_maxplan_perear = '1' THEN 1 ELSE 0 END) as per_ear_coverage_count,
        SUM(CASE WHEN pbp_b18b_maxplan_perear = '2' THEN 1 ELSE 0 END) as combined_ear_coverage_count

    FROM mimi_ws_1.partcd.pbp_b18_hearing_exams_aids
    WHERE pbp_b18b_bendesc_yn = '1' -- Only include plans with hearing aid coverage
    AND pbp_b18b_maxplan_yn = '1' -- Only include plans with maximum coverage limits
    GROUP BY 1,2,3
)

SELECT 
    pbp_a_plan_type,
    COUNT(*) as plan_count,
    ROUND(AVG(avg_max_coverage_amount),2) as typical_coverage_amount,
    ROUND(AVG(yearly_coverage_count * 100.0 / total_plans),1) as pct_yearly_coverage,
    ROUND(AVG(two_year_coverage_count * 100.0 / total_plans),1) as pct_two_year_coverage,
    ROUND(AVG(three_year_coverage_count * 100.0 / total_plans),1) as pct_three_year_coverage,
    ROUND(AVG(per_ear_coverage_count * 100.0 / total_plans),1) as pct_per_ear_coverage
FROM coverage_summary
GROUP BY 1
ORDER BY plan_count DESC;

/* How it works:
1. First CTE summarizes coverage patterns at the plan level
2. Main query aggregates by plan type to show market-wide patterns
3. Calculates percentages for different coverage periods and benefit structures

Assumptions and Limitations:
- Only includes plans that explicitly specify hearing aid coverage and maximum limits
- Assumes monetary amounts are comparable across plans (no adjustment for network differences)
- Does not account for mid-year benefit changes

Possible Extensions:
1. Add geographic analysis to identify regional coverage patterns
2. Compare coverage trends over multiple years to identify market shifts
3. Add correlation analysis with plan premiums or enrollment numbers
4. Include analysis of authorization requirements and referral patterns
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:23:13.540887
    - Additional Notes: Query focuses on maximum benefit amounts and coverage periods across plan types. Requires non-null values in pbp_b18b_maxplan_amt field for meaningful results. Coverage percentages may not sum to 100% if plans have overlapping or alternative coverage periods.
    
    */