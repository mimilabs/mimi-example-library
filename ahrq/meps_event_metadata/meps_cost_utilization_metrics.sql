-- MEPS Event Metadata - Healthcare Cost and Utilization Pattern Analysis
--
-- Business Purpose: 
-- Analyze MEPS event metadata to identify key variables related to cost and utilization
-- patterns across different types of healthcare services. This helps healthcare organizations
-- understand available metrics for financial planning, resource allocation, and 
-- population health management.

WITH cost_vars AS (
    -- Identify variables related to costs and payments
    SELECT DISTINCT category, varname, desc
    FROM mimi_ws_1.ahrq.meps_event_metadata
    WHERE LOWER(desc) LIKE '%payment%'
        OR LOWER(desc) LIKE '%charge%'
        OR LOWER(desc) LIKE '%expense%'
        OR LOWER(desc) LIKE '%expenditure%'
),

utilization_vars AS (
    -- Identify variables related to service utilization
    SELECT DISTINCT category, varname, desc
    FROM mimi_ws_1.ahrq.meps_event_metadata
    WHERE LOWER(desc) LIKE '%visit%'
        OR LOWER(desc) LIKE '%stay%'
        OR LOWER(desc) LIKE '%service%'
        OR LOWER(desc) LIKE '%procedure%'
)

-- Combine and summarize cost and utilization variables by category
SELECT 
    m.category,
    COUNT(DISTINCT CASE WHEN cv.varname IS NOT NULL THEN cv.varname END) as cost_variable_count,
    COUNT(DISTINCT CASE WHEN uv.varname IS NOT NULL THEN uv.varname END) as utilization_variable_count,
    CONCAT_WS(', ', COLLECT_SET(cv.varname)) as cost_variables,
    CONCAT_WS(', ', COLLECT_SET(uv.varname)) as utilization_variables
FROM mimi_ws_1.ahrq.meps_event_metadata m
LEFT JOIN cost_vars cv ON m.category = cv.category 
LEFT JOIN utilization_vars uv ON m.category = uv.category
GROUP BY m.category
ORDER BY m.category;

-- How this query works:
-- 1. Creates two CTEs to identify variables related to costs and utilization
-- 2. Joins these CTEs back to the main metadata table
-- 3. Aggregates results by category to show available metrics
-- 4. Uses COLLECT_SET and CONCAT_WS to create comma-separated lists of variables

-- Assumptions and limitations:
-- - Uses keyword matching to identify relevant variables
-- - May miss some variables if descriptions use different terminology
-- - Focused only on direct cost and utilization metrics
-- - Does not account for changes in variables across years

-- Possible extensions:
-- 1. Add temporal analysis to show how metrics evolved over time
-- 2. Include payer-specific variables (Medicare, Medicaid, private insurance)
-- 3. Add condition-specific or demographic variables
-- 4. Create category-specific metric scorecards
-- 5. Analyze availability of quality metrics alongside cost/utilization

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:41:04.953094
    - Additional Notes: The query identifies and categorizes healthcare cost and utilization variables across different medical event types. It uses keyword matching in variable descriptions to classify metrics, which may need periodic updates to capture new terminology. Results are aggregated at the category level, providing both counts and detailed lists of relevant variables.
    
    */