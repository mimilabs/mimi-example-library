-- Title: Medicare Advantage Plan Market Entry and Exit Analysis
-- Business Purpose: Identify market dynamics by tracking new plan entries and exits
-- across counties to support strategic market expansion and competitive analysis.
-- This helps insurers and providers understand market opportunities and competitive threats.

WITH current_period AS (
    -- Get the most recent reporting period
    SELECT MAX(mimi_src_file_date) as latest_date
    FROM mimi_ws_1.partcd.cpsc_enrollment
),

prior_period AS (
    -- Get the period one year ago by selecting min date from same month last year
    SELECT MAX(mimi_src_file_date) as prior_date
    FROM mimi_ws_1.partcd.cpsc_enrollment
    WHERE YEAR(mimi_src_file_date) = YEAR(CURRENT_DATE()) - 1
    AND MONTH(mimi_src_file_date) = MONTH(CURRENT_DATE())
),

market_changes AS (
    -- Compare plan presence between current and prior periods
    SELECT 
        COALESCE(curr.state, prev.state) as state,
        COALESCE(curr.county, prev.county) as county,
        COALESCE(curr.contract_number, prev.contract_number) as contract_number,
        COALESCE(curr.plan_id, prev.plan_id) as plan_id,
        CASE 
            WHEN curr.enrollment IS NOT NULL AND prev.enrollment IS NULL THEN 'New Entry'
            WHEN curr.enrollment IS NULL AND prev.enrollment IS NOT NULL THEN 'Exit'
            ELSE 'Existing'
        END as market_status,
        COALESCE(curr.enrollment, 0) as current_enrollment,
        COALESCE(prev.enrollment, 0) as prior_enrollment
    FROM 
        (SELECT DISTINCT state, county, contract_number, plan_id, enrollment 
         FROM mimi_ws_1.partcd.cpsc_enrollment e
         CROSS JOIN current_period c
         WHERE e.mimi_src_file_date = c.latest_date) curr
    FULL OUTER JOIN 
        (SELECT DISTINCT state, county, contract_number, plan_id, enrollment
         FROM mimi_ws_1.partcd.cpsc_enrollment e
         CROSS JOIN prior_period p
         WHERE e.mimi_src_file_date = p.prior_date) prev
    ON curr.state = prev.state 
    AND curr.county = prev.county
    AND curr.contract_number = prev.contract_number
    AND curr.plan_id = prev.plan_id
)

SELECT 
    state,
    county,
    COUNT(DISTINCT CASE WHEN market_status = 'New Entry' THEN contract_number || plan_id END) as new_plans,
    COUNT(DISTINCT CASE WHEN market_status = 'Exit' THEN contract_number || plan_id END) as exited_plans,
    SUM(CASE WHEN market_status = 'New Entry' THEN current_enrollment ELSE 0 END) as new_plan_enrollment,
    SUM(CASE WHEN market_status = 'Exit' THEN prior_enrollment ELSE 0 END) as lost_enrollment,
    SUM(current_enrollment) as total_current_enrollment
FROM market_changes
GROUP BY state, county
HAVING new_plans > 0 OR exited_plans > 0
ORDER BY new_plans DESC, exited_plans DESC;

-- How it works:
-- 1. Identifies the most recent data period and the corresponding period from previous year
-- 2. Compares plan presence between these periods to identify entries and exits
-- 3. Uses COALESCE to handle ambiguous column references in the FULL OUTER JOIN
-- 4. Aggregates results by state and county to show market dynamics
-- 5. Calculates enrollment impact of market changes

-- Assumptions and Limitations:
-- - Assumes monthly data availability
-- - Does not account for plan mergers or acquisitions
-- - May not capture mid-year market changes
-- - Focuses on net changes rather than member movement between plans
-- - Requires at least one year of historical data

-- Possible Extensions:
-- 1. Add contract organization names to identify specific insurers
-- 2. Calculate market concentration metrics (HHI) before and after changes
-- 3. Include demographic data to understand market attractiveness
-- 4. Analyze seasonal patterns in market entry/exit
-- 5. Compare rural vs urban market dynamics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:07:14.514279
    - Additional Notes: Query tracks year-over-year Medicare Advantage plan entries and exits at county level. Requires data from current and previous year in same month for accurate comparison. The COALESCE functions in the market_changes CTE are critical for handling cases where plans appear in only one time period.
    
    */