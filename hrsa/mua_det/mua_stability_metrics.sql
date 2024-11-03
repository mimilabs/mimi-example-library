-- mua_service_continuity_analysis.sql
-- Title: Medically Underserved Area Service Continuity and Stability Assessment

-- Business Purpose:
-- Analyzes the stability and continuity of MUA/P designations by examining breaks in service,
-- designation updates, and withdrawals. This helps identify areas with unstable healthcare
-- access and potential service disruptions, supporting resource allocation and intervention
-- planning for maintaining consistent healthcare coverage.

WITH active_designations AS (
    -- Filter for current active designations and calculate designation duration
    SELECT 
        muap_id,
        muap_service_area_name,
        designation_type,
        state_name,
        designation_date,
        muap_update_date,
        medically_underserved_area_population_muap_withdrawal_date,
        break_in_designation,
        imu_score,
        DATEDIFF(day, designation_date, COALESCE(
            medically_underserved_area_population_muap_withdrawal_date,
            CURRENT_DATE
        )) as designation_duration_days
    FROM mimi_ws_1.hrsa.mua_det
    WHERE muap_status_description = 'Designated'
)

SELECT 
    state_name,
    COUNT(muap_id) as total_designations,
    -- Calculate stability metrics
    ROUND(AVG(designation_duration_days)/365.25, 1) as avg_years_designated,
    ROUND(AVG(imu_score), 1) as avg_imu_score,
    COUNT(CASE WHEN break_in_designation = 'Y' THEN 1 END) as designations_with_breaks,
    COUNT(CASE WHEN medically_underserved_area_population_muap_withdrawal_date IS NOT NULL THEN 1 END) as withdrawn_designations,
    -- Calculate percentage of stable designations
    ROUND(100.0 * COUNT(CASE WHEN break_in_designation = 'N' THEN 1 END) / COUNT(*), 1) as pct_stable_designations
FROM active_designations
GROUP BY state_name
HAVING COUNT(muap_id) >= 5  -- Focus on states with meaningful sample sizes
ORDER BY avg_imu_score ASC;

-- How the Query Works:
-- 1. Creates a CTE focusing on active designations and calculating their duration
-- 2. Aggregates by state to show key stability metrics
-- 3. Includes various measures of designation stability and continuity
-- 4. Filters for states with at least 5 designations for statistical relevance

-- Assumptions and Limitations:
-- - Assumes current date for ongoing designations without withdrawal dates
-- - Limited to currently active designations only
-- - Requires at least 5 designations per state for inclusion
-- - Break in designation is treated as a binary variable

-- Possible Extensions:
-- 1. Add trending analysis to show stability changes over time
-- 2. Include geographic clustering analysis of unstable designations
-- 3. Cross-reference with provider ratios to identify correlations
-- 4. Add designation type (MUA vs MUP) breakdown
-- 5. Incorporate rural/urban classification in stability analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:31:53.082514
    - Additional Notes: The query provides aggregated stability metrics at state level with a threshold of 5+ designations per state. The IMU score ordering highlights states with the most critical underservice levels among those with stable measurement periods. Consider adjusting the threshold of 5 designations based on specific analysis needs.
    
    */