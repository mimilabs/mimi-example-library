-- Monitoring_Active_Healthcare_Exclusions.sql

-- Business Purpose:
-- This query provides a critical monitoring dashboard for healthcare compliance officers and administrators
-- by identifying currently active exclusions that require immediate attention. It helps organizations:
-- 1. Track active exclusions without reinstatement dates
-- 2. Identify high-risk providers with valid NPIs
-- 3. Understand the duration of active exclusions
-- 4. Support compliance monitoring requirements

WITH active_exclusions AS (
    -- Focus on currently active exclusions
    SELECT 
        COALESCE(busname, CONCAT(lastname, ', ', firstname)) as provider_name,
        npi,
        general as provider_type,
        specialty,
        state,
        excldate,
        DATEDIFF(CURRENT_DATE(), excldate) as days_excluded,
        excl_description
    FROM mimi_ws_1.hhsoig.leie
    WHERE reindate IS NULL 
    AND excldate IS NOT NULL
    AND npi != '0000000000'  -- Focus on providers with valid NPIs
)

SELECT 
    provider_type,
    COUNT(*) as active_exclusion_count,
    ROUND(AVG(days_excluded),0) as avg_days_excluded,
    COUNT(CASE WHEN days_excluded > 365 THEN 1 END) as exclusions_over_1year,
    CONCAT_WS(', ', COLLECT_SET(state)) as affected_states,
    MIN(excldate) as earliest_exclusion,
    MAX(excldate) as latest_exclusion
FROM active_exclusions
GROUP BY provider_type
HAVING COUNT(*) > 5  -- Focus on provider types with meaningful patterns
ORDER BY active_exclusion_count DESC;

-- How it works:
-- 1. Creates a CTE focusing on active exclusions (no reinstatement date)
-- 2. Combines business names and individual names for consistent provider identification
-- 3. Calculates exclusion duration in days
-- 4. Aggregates data by provider type to show patterns
-- 5. Includes only provider types with more than 5 active exclusions

-- Assumptions and Limitations:
-- 1. Assumes current date for exclusion duration calculations
-- 2. Focuses only on providers with valid NPIs (excludes entities without NPIs)
-- 3. Does not account for potential data entry delays or updates
-- 4. Groups by general provider type which may mask specialty-specific patterns

-- Possible Extensions:
-- 1. Add trend analysis by comparing current month to previous months
-- 2. Include geographic heat mapping by state
-- 3. Add specialty-level analysis within each provider type
-- 4. Create alerts for newly added high-risk provider types
-- 5. Add comparison to industry benchmarks if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:51:18.903128
    - Additional Notes: The query provides an aggregate view of currently active healthcare provider exclusions, focusing on valid NPI holders. It uses COLLECT_SET for state aggregation which may have performance implications on very large datasets. The 5-exclusion threshold in the HAVING clause can be adjusted based on monitoring needs.
    
    */