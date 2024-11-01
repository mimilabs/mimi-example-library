-- MEPS Event Metadata - Temporal Analysis of Healthcare Data Elements
-- Business Purpose: Analyze how MEPS data collection has evolved over time by identifying
-- new and discontinued variables across survey years. This helps researchers and analysts
-- understand data availability trends and plan longitudinal studies appropriately.

WITH yearly_vars AS (
    -- Get distinct variables by year
    SELECT DISTINCT
        year,
        varname,
        category,
        desc
    FROM mimi_ws_1.ahrq.meps_event_metadata
),

var_history AS (
    -- Calculate first and last appearance of each variable
    SELECT 
        varname,
        MIN(year) as first_year,
        MAX(year) as last_year,
        MAX(category) as latest_category,
        MAX(desc) as latest_desc
    FROM yearly_vars
    GROUP BY varname
),

summary_stats AS (
    -- Identify variables added or discontinued
    SELECT
        varname,
        first_year,
        last_year,
        latest_category,
        latest_desc,
        CASE 
            WHEN last_year = (SELECT MAX(year) FROM yearly_vars) THEN 'Current'
            ELSE 'Discontinued'
        END as status
    FROM var_history
)

SELECT
    status,
    latest_category,
    first_year,
    last_year,
    varname,
    latest_desc
FROM summary_stats
WHERE (first_year > (SELECT MIN(year) FROM yearly_vars) OR  -- New variables
       last_year < (SELECT MAX(year) FROM yearly_vars))     -- Discontinued variables
ORDER BY status, latest_category, first_year DESC;

-- How it works:
-- 1. Creates a base table of distinct variables by year
-- 2. Calculates the first and last appearance of each variable
-- 3. Identifies variables that were either added after the first survey year
--    or discontinued before the most recent year
-- 4. Returns a comprehensive view of variable changes over time

-- Assumptions and Limitations:
-- - Assumes gaps in years indicate discontinuation rather than missing metadata
-- - Does not track changes in variable descriptions or categories over time
-- - May not capture temporary variables that appeared and disappeared between years

-- Possible Extensions:
-- 1. Add counts of affected records for each variable change
-- 2. Include analysis of changes in variable types (format changes)
-- 3. Group changes by major MEPS survey redesign periods
-- 4. Add comparison with other healthcare surveys' variable evolution
-- 5. Create metrics for data consistency across years

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:49:03.981254
    - Additional Notes: Query tracks the lifecycle of MEPS survey variables across years, focusing on identifying newly introduced and discontinued data elements. Best used for longitudinal study planning and understanding data collection evolution patterns. Performance may be impacted with very large date ranges.
    
    */