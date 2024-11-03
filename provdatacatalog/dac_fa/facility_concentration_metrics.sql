-- facility_type_concentration.sql

-- Business Purpose: Analyze the concentration and diversity of facility affiliations
-- to identify potential network optimization opportunities and risk areas where
-- services may be too concentrated in certain facility types.
-- This insight helps:
-- 1. Network planning and risk management
-- 2. Strategic partnership decisions
-- 3. Resource allocation across facility types

WITH provider_facility_counts AS (
    -- Get counts of providers per facility type
    SELECT 
        facility_type,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT facility_affiliations_certification_number) as facility_count,
        COUNT(*) as total_affiliations
    FROM mimi_ws_1.provdatacatalog.dac_fa
    WHERE facility_type IS NOT NULL
    GROUP BY facility_type
),
metrics AS (
    -- Calculate concentration metrics
    SELECT 
        facility_type,
        provider_count,
        facility_count,
        total_affiliations,
        ROUND(total_affiliations / CAST(facility_count AS FLOAT), 2) as avg_affiliations_per_facility,
        ROUND(total_affiliations / CAST(provider_count AS FLOAT), 2) as avg_facilities_per_provider,
        ROUND(provider_count / CAST(facility_count AS FLOAT), 2) as provider_facility_ratio
    FROM provider_facility_counts
)
SELECT 
    facility_type,
    provider_count,
    facility_count,
    avg_affiliations_per_facility,
    avg_facilities_per_provider,
    provider_facility_ratio,
    RANK() OVER (ORDER BY provider_facility_ratio DESC) as concentration_rank
FROM metrics
ORDER BY concentration_rank;

-- How this query works:
-- 1. First CTE calculates basic counts per facility type
-- 2. Second CTE derives key concentration metrics
-- 3. Final SELECT adds ranking to identify most concentrated facility types

-- Assumptions and Limitations:
-- 1. Assumes all facility affiliations are equally weighted
-- 2. Does not account for geographical distribution
-- 3. Current snapshot only - no historical trending
-- 4. Null facility types are excluded

-- Possible Extensions:
-- 1. Add geographical dimension (state/region level analysis)
-- 2. Include temporal analysis to show concentration changes
-- 3. Add specialty-specific concentration analysis
-- 4. Compare against quality metrics or patient outcomes
-- 5. Add facility size/capacity weighting when available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:45:58.974479
    - Additional Notes: This query focuses on network density metrics and may need adjustment for very large datasets due to the window function (RANK) operation. Consider adding WHERE clauses for specific time periods or facility types if performance is a concern.
    
    */