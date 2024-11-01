-- rhc_practice_location_profiling.sql

-- Business Purpose:
-- This query analyzes the practice location patterns of Rural Health Clinics (RHCs)
-- to identify potential healthcare access patterns and delivery model variations by:
-- - Examining the relationship between physical locations and organizational structures
-- - Identifying areas with high concentration of similar RHC delivery models
-- - Understanding practice location patterns that could inform healthcare access strategies

SELECT 
    -- Group by key location and organizational dimensions
    state,
    organization_type_structure,
    proprietary_nonprofit,
    
    -- Calculate key metrics
    COUNT(DISTINCT enrollment_id) as total_clinics,
    COUNT(DISTINCT zip_code) as unique_zip_codes,
    COUNT(DISTINCT city) as unique_cities,
    
    -- Calculate density metrics
    ROUND(COUNT(DISTINCT enrollment_id)::FLOAT / COUNT(DISTINCT zip_code), 2) as clinics_per_zipcode,
    
    -- Calculate organizational composition
    ROUND(100.0 * SUM(CASE WHEN multiple_npi_flag = 'Y' THEN 1 ELSE 0 END) / 
          COUNT(enrollment_id), 2) as pct_multiple_npi,
          
    -- Latest incorporation date to understand market maturity
    MAX(incorporation_date) as latest_incorporation_date

FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic

WHERE state IS NOT NULL
  AND organization_type_structure IS NOT NULL

GROUP BY 
    state,
    organization_type_structure,
    proprietary_nonprofit

HAVING COUNT(DISTINCT enrollment_id) >= 5  -- Focus on meaningful groupings

ORDER BY 
    total_clinics DESC,
    state,
    organization_type_structure;

-- How this query works:
-- 1. Groups RHCs by state, organization type, and profit status
-- 2. Calculates various density and concentration metrics
-- 3. Filters for groups with meaningful sample sizes
-- 4. Orders results to highlight areas with highest clinic presence

-- Assumptions and Limitations:
-- - Assumes current addresses are accurate and up-to-date
-- - ZIP code based analysis may not perfectly represent service areas
-- - Does not account for population density or demographic factors
-- - Multiple locations in same ZIP may indicate different access patterns

-- Possible Extensions:
-- 1. Add geographic clustering analysis using ZIP code patterns
-- 2. Incorporate distance calculations between facilities
-- 3. Add temporal analysis of location pattern changes
-- 4. Include demographic data overlay for served populations
-- 5. Add analysis of urban vs rural ZIP code distributions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:21:52.812328
    - Additional Notes: The query calculates density metrics and organizational patterns of Rural Health Clinics at state/zip level. For meaningful analysis, ensure the state and organization_type_structure fields are properly populated, as NULL values are excluded. The 5-clinic minimum threshold in the HAVING clause may need adjustment based on specific analysis needs.
    
    */