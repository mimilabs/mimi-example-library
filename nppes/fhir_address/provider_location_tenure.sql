-- Title: Active Provider Location Timeline Analysis
-- Business Purpose: Analyzes the temporal patterns of provider practice locations
-- to identify provider mobility trends, practice stability, and potential 
-- service disruptions in healthcare delivery networks. This information supports
-- network planning, provider retention strategies, and continuity of care initiatives.

SELECT 
    npi,
    city,
    state,
    -- Calculate the duration in months for each address
    MONTHS_BETWEEN(COALESCE(period_end, CURRENT_DATE()), period_start) as months_at_location,
    period_start,
    period_end,
    -- Identify if location is current (no end date)
    CASE WHEN period_end IS NULL THEN 'Active' ELSE 'Historical' END as location_status
FROM mimi_ws_1.nppes.fhir_address
WHERE 
    -- Focus on business/practice addresses
    use = 'work'
    -- Ensure valid period start dates
    AND period_start IS NOT NULL
    -- Look at last 5 years of data
    AND period_start >= ADD_MONTHS(CURRENT_DATE(), -60)
ORDER BY 
    npi,
    period_start DESC;

-- How this query works:
-- 1. Filters for work addresses only to focus on practice locations
-- 2. Calculates duration at each location using MONTHS_BETWEEN
-- 3. Identifies current vs historical locations
-- 4. Orders results chronologically by provider

-- Assumptions and Limitations:
-- - Assumes work addresses represent actual practice locations
-- - Limited to last 5 years of data
-- - NULL period_end dates interpreted as current locations
-- - Does not account for potential data entry delays or updates

-- Possible Extensions:
-- 1. Add geographic clustering to identify provider movement patterns
-- 2. Calculate average tenure by geographic area or provider type
-- 3. Identity providers with frequent location changes
-- 4. Compare rural vs urban location stability
-- 5. Cross-reference with quality metrics to assess impact of provider mobility

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:25:49.906373
    - Additional Notes: Query focuses on measuring provider stability through location duration analysis. Performance may be impacted when analyzing large date ranges due to the MONTHS_BETWEEN calculation. Consider adding indexes on period_start and use columns if frequent execution is needed.
    
    */