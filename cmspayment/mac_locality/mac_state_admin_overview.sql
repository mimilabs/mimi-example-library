-- mac_locality_state_carrier_overview.sql
-- Business Purpose: Provide a high-level overview of Medicare Administrative Contractor (MAC)
-- relationships across states and carriers to help healthcare organizations understand
-- the administrative landscape and plan their operations accordingly.

WITH state_carrier_metrics AS (
    -- Calculate key metrics per state
    SELECT 
        state_name,
        COUNT(DISTINCT mac_id) AS unique_macs,
        COUNT(DISTINCT carrier_key) AS unique_carriers,
        COUNT(DISTINCT locality_number) AS unique_localities,
        -- Get most recent reporting date per state
        MAX(mimi_src_file_date) AS latest_data_date
    FROM mimi_ws_1.cmspayment.mac_locality
    GROUP BY state_name
),
carrier_coverage AS (
    -- Identify carriers serving multiple states
    SELECT
        carrier_key,
        COUNT(DISTINCT state_name) AS states_covered
    FROM mimi_ws_1.cmspayment.mac_locality
    GROUP BY carrier_key
)
SELECT 
    m.state_name,
    m.unique_macs,
    m.unique_carriers,
    m.unique_localities,
    ROUND(m.unique_localities * 1.0 / m.unique_carriers, 2) AS avg_localities_per_carrier,
    EXISTS (
        SELECT 1 
        FROM carrier_coverage c
        JOIN mimi_ws_1.cmspayment.mac_locality ml ON c.carrier_key = ml.carrier_key
        WHERE ml.state_name = m.state_name AND c.states_covered > 1
    ) AS has_multistate_carriers,
    DATE_TRUNC('month', m.latest_data_date) AS data_month
FROM state_carrier_metrics m
ORDER BY m.state_name;

-- How this query works:
-- 1. Creates a CTE to aggregate state-level metrics including counts of unique MACs,
--    carriers, and localities
-- 2. Creates a second CTE to identify carriers operating across multiple states
-- 3. Combines the information to provide a comprehensive view of MAC/carrier relationships
--    by state, including a calculated metric for administrative complexity

-- Assumptions and Limitations:
-- - Assumes current data in the table represents active MAC/carrier relationships
-- - Does not account for historical changes in relationships
-- - May not reflect pending administrative changes or transitions
-- - Locality numbers may have different meanings across different carriers

-- Possible Extensions:
-- 1. Add temporal analysis to track relationship changes over time
-- 2. Include geographic clustering analysis for multi-state carriers
-- 3. Incorporate additional metrics like population served or Medicare enrollment
-- 4. Add comparison with national averages for each metric
-- 5. Include carrier details or MAC information through joins with related tables

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:40:26.168652
    - Additional Notes: Query provides administrative complexity insights but only reflects current state of MAC/carrier relationships. Performance may be impacted for large datasets due to EXISTS subquery. Consider adding index on carrier_key and state_name for better performance.
    
    */