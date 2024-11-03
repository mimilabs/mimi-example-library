-- healthcare_reinstatement_trends.sql

-- Business Purpose:
-- Analyzes reinstatement patterns of excluded healthcare providers to:
-- 1. Measure average duration of exclusions before reinstatement
-- 2. Identify provider types most likely to achieve reinstatement
-- 3. Track reinstatement success rates over time
-- This helps healthcare organizations understand rehabilitation patterns and
-- make informed decisions about potential future hires.

WITH base_metrics AS (
    -- Calculate exclusion durations and flag successful reinstatements
    SELECT 
        COALESCE(busname, CONCAT(lastname, ', ', firstname)) as provider_name,
        general,
        specialty,
        excldate,
        reindate,
        state,
        DATEDIFF(reindate, excldate) as days_until_reinstatement,
        CASE WHEN reindate IS NOT NULL THEN 1 ELSE 0 END as was_reinstated
    FROM mimi_ws_1.hhsoig.leie
    WHERE excldate IS NOT NULL
),

annual_trends AS (
    -- Aggregate reinstatement metrics by year
    SELECT 
        YEAR(excldate) as exclusion_year,
        COUNT(*) as total_exclusions,
        SUM(was_reinstated) as total_reinstated,
        ROUND(AVG(CASE WHEN was_reinstated = 1 THEN days_until_reinstatement END)/365.25, 1) as avg_years_to_reinstate
    FROM base_metrics
    GROUP BY YEAR(excldate)
),

provider_type_analysis AS (
    -- Analyze reinstatement patterns by provider type
    SELECT 
        general,
        COUNT(*) as total_providers,
        SUM(was_reinstated) as reinstated_count,
        ROUND(100.0 * SUM(was_reinstated) / COUNT(*), 1) as reinstatement_rate
    FROM base_metrics
    WHERE general IS NOT NULL
    GROUP BY general
    HAVING COUNT(*) >= 10
)

-- Combine key insights from both analyses
SELECT
    'Overall Summary' as metric,
    COUNT(*) as total_cases,
    ROUND(100.0 * SUM(was_reinstated) / COUNT(*), 1) as overall_reinstatement_rate,
    ROUND(AVG(CASE WHEN was_reinstated = 1 THEN days_until_reinstatement END)/365.25, 1) as avg_years_to_reinstate
FROM base_metrics

UNION ALL

SELECT 
    'Provider Type: ' || general,
    total_providers,
    reinstatement_rate,
    NULL as avg_years
FROM provider_type_analysis
WHERE reinstatement_rate > 0
ORDER BY total_cases DESC;

-- How it works:
-- 1. Base metrics CTE establishes core dataset of exclusions and reinstatements
-- 2. Annual trends CTE calculates yearly patterns
-- 3. Provider type analysis CTE examines reinstatement rates by provider category
-- 4. Final query combines overall summary with provider type breakdowns

-- Assumptions and limitations:
-- 1. Assumes reindate field is consistently populated when reinstatement occurs
-- 2. Limited to providers with valid exclusion dates
-- 3. Provider type analysis requires at least 10 cases per category
-- 4. Does not account for potential data quality issues in dates

-- Possible extensions:
-- 1. Add geographic analysis of reinstatement rates by state
-- 2. Include trend analysis over specific time periods
-- 3. Correlate reinstatement rates with exclusion reasons
-- 4. Add seasonal patterns analysis of reinstatements
-- 5. Include analysis of waiver patterns using waiverdate field

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:25:14.363038
    - Additional Notes: Query focuses on reinstatement success rates and timing patterns. Requires sufficient historical data with valid reinstatement dates for meaningful analysis. Performance may be impacted with very large datasets due to date calculations and multiple CTEs.
    
    */