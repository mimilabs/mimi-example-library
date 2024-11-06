-- mortality_followup_metrics.sql
-- Business Purpose: Analyze mortality follow-up patterns and eligibility characteristics
-- to assess data completeness and identify potential gaps in longitudinal tracking.
-- This analysis helps validate data quality and informs study design decisions.

WITH follow_up_stats AS (
    -- Calculate key follow-up metrics for eligible participants
    SELECT 
        eligstat,
        COUNT(*) as total_participants,
        ROUND(AVG(CASE WHEN mortstat = 1 THEN permth_int ELSE NULL END)/12, 1) as avg_years_to_death,
        ROUND(AVG(permth_int)/12, 1) as avg_years_follow_up,
        COUNT(CASE WHEN mortstat = 1 THEN 1 END) as deceased_count,
        COUNT(CASE WHEN mortstat = 0 THEN 1 END) as alive_count
    FROM mimi_ws_1.cdc.nhanes_mortality
    GROUP BY eligstat
)

SELECT
    CASE 
        WHEN eligstat = 1 THEN 'Eligible'
        WHEN eligstat = 2 THEN 'Under 18'
        WHEN eligstat = 3 THEN 'Ineligible'
        ELSE 'Unknown'
    END as eligibility_status,
    total_participants,
    deceased_count,
    alive_count,
    avg_years_to_death as avg_survival_years,
    avg_years_follow_up as avg_followup_years,
    ROUND(100.0 * deceased_count / NULLIF(total_participants, 0), 1) as mortality_rate_pct
FROM follow_up_stats
ORDER BY eligstat;

-- How this query works:
-- 1. Creates a CTE to aggregate key follow-up metrics by eligibility status
-- 2. Calculates average follow-up times and mortality counts
-- 3. Presents results with descriptive labels and derived metrics
-- 4. Converts months to years for better interpretability

-- Assumptions and Limitations:
-- - Assumes permth_int is properly recorded for all participants
-- - Does not account for possible censoring effects
-- - Mortality status might be uncertain for some participants
-- - Follow-up times may vary by cohort/study period

-- Possible Extensions:
-- 1. Add temporal trends by including mimi_src_file_date analysis
-- 2. Segment analysis by examination vs interview follow-up times
-- 3. Create cohort-specific follow-up patterns
-- 4. Add data quality metrics like missing value percentages
-- 5. Compare follow-up completeness across different data source files

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:45:02.798169
    - Additional Notes: The query provides essential data quality metrics for longitudinal mortality tracking, focusing on follow-up periods and eligibility distributions. This baseline analysis is particularly valuable for researchers validating cohort definitions and assessing potential selection bias in mortality studies.
    
    */