-- provider_practice_settings_analysis.sql

-- Business Purpose:
-- This query analyzes provider practice settings and service delivery models to help:
-- - Identify patterns in solo vs group practice arrangements
-- - Understand provider co-location trends
-- - Support facility planning and resource allocation decisions
-- - Guide patient access improvement initiatives

-- Main Query
SELECT 
    -- Analyze practice location patterns
    address,
    city,
    state,
    COUNT(DISTINCT npi) as provider_count,
    
    -- Examine practice composition
    COUNT(DISTINCT provider_type) as specialty_mix,
    
    -- Calculate co-location metrics
    CASE 
        WHEN COUNT(DISTINCT npi) = 1 THEN 'Solo Practice'
        WHEN COUNT(DISTINCT npi) BETWEEN 2 AND 5 THEN 'Small Group'
        WHEN COUNT(DISTINCT npi) BETWEEN 6 AND 20 THEN 'Large Group'
        ELSE 'Medical Center'
    END as practice_size_category,
    
    -- Get most recent data timestamp
    MAX(last_updated_on) as latest_update

FROM mimi_ws_1.datahealthcaregov.provider_addresses

-- Focus on current active locations
WHERE last_updated_on >= DATE_SUB(CURRENT_DATE(), 180)
AND address IS NOT NULL

-- Group by unique practice locations
GROUP BY address, city, state

-- Filter for meaningful practice locations
HAVING provider_count > 0

-- Order by locations with most providers first
ORDER BY provider_count DESC
LIMIT 1000;

-- How this query works:
-- 1. Groups providers by physical address to identify practice locations
-- 2. Calculates metrics about provider count and specialty mix at each location
-- 3. Categorizes practices by size based on provider count
-- 4. Focuses on recently active locations using a 180-day lookback
-- 5. Orders results to highlight largest practice locations first

-- Assumptions and Limitations:
-- - Assumes same address string indicates co-located providers
-- - Limited to last 180 days of data
-- - Practice size categories are simplified approximations
-- - Does not account for satellite offices or part-time locations
-- - Address variations may cause undercounting at some locations

-- Possible Extensions:
-- 1. Add temporal analysis to track practice size changes over time
-- 2. Include specialty-specific analysis of practice patterns
-- 3. Incorporate ZIP code demographics for market analysis
-- 4. Calculate distance between practice locations
-- 5. Add facility type classification based on provider mix
-- 6. Analyze regional variations in practice models

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:00:00.382264
    - Additional Notes: Query identifies healthcare delivery models by analyzing provider co-location patterns. Results are limited to 1000 locations and require data from the last 180 days. Address matching may be imperfect due to variations in address formatting. Practice size categories (Solo, Small Group, Large Group, Medical Center) are based on simplified thresholds that may need adjustment for specific markets.
    
    */