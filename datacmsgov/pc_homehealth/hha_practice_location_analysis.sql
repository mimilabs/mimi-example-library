-- Home Health Agency Practice Location Type Analysis
--
-- Business Purpose:
-- Analyzes practice location patterns of Medicare-enrolled home health agencies to:
-- 1. Understand types of facilities and settings where home health services originate
-- 2. Identify unique or specialized service delivery models
-- 3. Support facility planning and service area optimization
-- 4. Help identify compliance patterns with location requirements

WITH location_summary AS (
    -- Get the count and percentage of each practice location type
    SELECT 
        COALESCE(practice_location_type, 'Not Specified') as location_type,
        COUNT(*) as agency_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage,
        -- Calculate agencies with multiple locations
        COUNT(DISTINCT associate_id) as unique_agencies,
        ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT associate_id), 2) as avg_locations_per_agency
    FROM mimi_ws_1.datacmsgov.pc_homehealth
    GROUP BY practice_location_type
)

SELECT 
    location_type,
    agency_count,
    percentage as pct_of_total,
    unique_agencies,
    avg_locations_per_agency,
    -- Flag high-concentration location types
    CASE 
        WHEN percentage >= 10 THEN 'High Concentration'
        WHEN percentage >= 5 THEN 'Medium Concentration'
        ELSE 'Low Concentration'
    END as concentration_level
FROM location_summary
ORDER BY agency_count DESC;

-- How the Query Works:
-- 1. Creates a CTE to aggregate practice location types
-- 2. Calculates key metrics including total count, percentage, and averages
-- 3. Adds business context through concentration level classification
-- 4. Orders results by frequency to highlight dominant location types

-- Assumptions and Limitations:
-- 1. Assumes practice_location_type is relatively standardized
-- 2. Does not account for seasonal or temporal changes
-- 3. May include inactive or recently enrolled agencies
-- 4. Treats missing location types as 'Not Specified'

-- Possible Extensions:
-- 1. Add geographic dimension (state/region analysis)
-- 2. Cross-reference with proprietary_nonprofit status
-- 3. Include incorporation date to track location type trends
-- 4. Add location type analysis by organization structure
-- 5. Compare location patterns between chain and independent agencies

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:27:16.458291
    - Additional Notes: This query provides insights into facility types and service delivery models but should be combined with geographic analysis for complete location strategy planning. Location type standardization may vary across regions and over time.
    
    */