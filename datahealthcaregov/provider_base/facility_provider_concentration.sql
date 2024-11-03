-- provider_facility_concentration.sql
-- Business Purpose: Analyze healthcare facility concentration and provider distribution to:
-- 1. Identify key healthcare facilities with high provider counts
-- 2. Understand facility type mix and market concentration
-- 3. Support strategic planning for network development and facility partnerships
-- 4. Guide resource allocation and expansion decisions

WITH FacilityMetrics AS (
    -- Calculate provider counts and specialty diversity per facility
    SELECT 
        facility_name,
        facility_type,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT specialty) as specialty_count,
        COUNT(DISTINCT CASE WHEN accepting = 'Y' THEN npi END) as accepting_providers,
        ROUND(COUNT(DISTINCT CASE WHEN accepting = 'Y' THEN npi END) * 100.0 / 
              NULLIF(COUNT(DISTINCT npi), 0), 1) as pct_accepting
    FROM mimi_ws_1.datahealthcaregov.provider_base
    WHERE facility_name IS NOT NULL 
    GROUP BY facility_name, facility_type
),
FacilityRanking AS (
    -- Add rankings to identify top facilities
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY facility_type ORDER BY provider_count DESC) as rank_in_type,
        ROW_NUMBER() OVER (ORDER BY provider_count DESC) as overall_rank
    FROM FacilityMetrics
)
-- Present key facility metrics with rankings
SELECT 
    facility_name,
    facility_type,
    provider_count,
    specialty_count,
    accepting_providers,
    pct_accepting,
    rank_in_type as rank_within_facility_type,
    overall_rank
FROM FacilityRanking
WHERE rank_in_type <= 10  -- Show top 10 facilities within each type
ORDER BY facility_type, rank_in_type;

-- How this query works:
-- 1. First CTE (FacilityMetrics) aggregates provider data at the facility level
-- 2. Second CTE (FacilityRanking) adds rankings within facility type and overall
-- 3. Final SELECT filters for top facilities and presents key metrics
--
-- Assumptions and limitations:
-- - Assumes facility_name is consistently recorded
-- - Does not account for facility size or patient volume
-- - Rankings may be affected by data completeness
-- - Multiple locations of same facility chain may be recorded separately
--
-- Possible extensions:
-- 1. Add geographic dimension to analyze regional facility concentration
-- 2. Include trend analysis by comparing against historical data
-- 3. Add specialty mix analysis within top facilities
-- 4. Incorporate quality metrics or patient outcome data if available
-- 5. Calculate market share metrics by facility type
-- 6. Add provider turnover analysis by comparing across time periods

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:37:05.877644
    - Additional Notes: Query focuses on healthcare facility concentration metrics. Rankings are calculated both within facility types and overall, which may be resource-intensive for very large datasets. Consider adding WHERE clauses to filter by specific time periods or facility types if performance issues arise.
    
    */