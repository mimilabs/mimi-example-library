-- Title: Rate Expiration Risk Analysis for Contract Management
-- Business Purpose: 
-- - Identify contracts with negotiated rates nearing expiration to proactively manage renewals
-- - Prioritize high-value services requiring immediate contract attention
-- - Support strategic planning for rate renegotiations
-- - Prevent disruption in provider network coverage

WITH expiring_rates AS (
    -- Get rates expiring within next 90 days and their current values
    SELECT 
        reporting_entity_name,
        billing_code,
        billing_code_type,
        name as service_name,
        negotiated_rate,
        expiration_date,
        DATE_DIFF(expiration_date, CURRENT_DATE(), 'DAY') as days_until_expiration,
        billing_class,
        negotiation_arrangement
    FROM mimi_ws_1.payermrf.in_network_rates
    WHERE expiration_date IS NOT NULL
    AND expiration_date BETWEEN CURRENT_DATE() AND DATE_ADD(CURRENT_DATE(), 90)
)

SELECT 
    reporting_entity_name,
    billing_class,
    COUNT(*) as expiring_contracts,
    ROUND(AVG(negotiated_rate), 2) as avg_rate,
    MIN(days_until_expiration) as nearest_expiration,
    MAX(days_until_expiration) as furthest_expiration,
    -- Categorize urgency based on expiration timeline
    SUM(CASE 
        WHEN days_until_expiration <= 30 THEN 1 
        ELSE 0 
    END) as critical_30_days,
    SUM(CASE 
        WHEN days_until_expiration > 30 AND days_until_expiration <= 60 THEN 1 
        ELSE 0 
    END) as warning_60_days,
    SUM(CASE 
        WHEN days_until_expiration > 60 THEN 1 
        ELSE 0 
    END) as upcoming_90_days
FROM expiring_rates
GROUP BY reporting_entity_name, billing_class
ORDER BY critical_30_days DESC, avg_rate DESC;

-- How it works:
-- 1. Creates a CTE to identify rates expiring within 90 days
-- 2. Calculates days until expiration for each contract
-- 3. Aggregates data by payer and billing class
-- 4. Categories contracts by urgency (30/60/90 day windows)
-- 5. Orders results prioritizing critical expirations and higher value contracts

-- Assumptions & Limitations:
-- - Assumes expiration_date is populated and accurate
-- - Does not account for auto-renewal terms
-- - Focused on time-based risk rather than financial impact
-- - Limited to 90-day forward-looking window

-- Possible Extensions:
-- 1. Add financial impact analysis by including volume/utilization data
-- 2. Compare expiring rates with market benchmarks
-- 3. Include provider group information for network impact assessment
-- 4. Expand to historical analysis of renewal patterns
-- 5. Add geographical analysis to identify regional contract risks

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:09:42.129757
    - Additional Notes: Query focuses on contract expiration risk management with 30/60/90 day monitoring windows. Best used for quarterly contract renewal planning and risk assessment. Requires regular data updates to maintain accuracy of expiration dates.
    
    */