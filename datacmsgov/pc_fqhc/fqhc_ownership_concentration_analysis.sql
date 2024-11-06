
-- TITLE: FQHC Ownership Concentration and Market Penetration Analysis

-- BUSINESS PURPOSE:
-- Analyze the concentration of FQHC ownership across different states and organization types
-- Identify potential healthcare market consolidation patterns
-- Provide insights into the organizational structure of community healthcare providers

WITH fqhc_ownership_analysis AS (
    -- Count the number of unique FQHCs per state and organization type
    SELECT 
        state,
        organization_type_structure,
        proprietary_nonprofit,
        COUNT(DISTINCT enrollment_id) AS total_fqhc_count,
        COUNT(DISTINCT associate_id) AS unique_owner_count,
        -- Calculate average number of FQHCs per owner in each state/org type
        ROUND(COUNT(DISTINCT enrollment_id) * 1.0 / NULLIF(COUNT(DISTINCT associate_id), 0), 2) AS avg_fqhcs_per_owner,
        -- Identify states with highest ownership concentration
        RANK() OVER (ORDER BY COUNT(DISTINCT enrollment_id) DESC) AS state_fqhc_rank
    FROM 
        mimi_ws_1.datacmsgov.pc_fqhc
    WHERE 
        state IS NOT NULL 
        AND organization_type_structure IS NOT NULL
    GROUP BY 
        state, 
        organization_type_structure, 
        proprietary_nonprofit
)

-- Main query to analyze ownership concentration
SELECT 
    state,
    organization_type_structure,
    proprietary_nonprofit,
    total_fqhc_count,
    unique_owner_count,
    avg_fqhcs_per_owner,
    state_fqhc_rank,
    -- Calculate market penetration percentage
    ROUND(total_fqhc_count * 100.0 / SUM(total_fqhc_count) OVER (), 2) AS market_share_pct
FROM 
    fqhc_ownership_analysis
WHERE 
    total_fqhc_count > 5  -- Focus on states with meaningful FQHC presence
ORDER BY 
    total_fqhc_count DESC, 
    avg_fqhcs_per_owner DESC
LIMIT 50;

-- QUERY EXPLANATION:
-- 1. Creates a CTE to aggregate FQHC counts by state, organization type, and profit status
-- 2. Calculates total FQHCs, unique owners, and average FQHCs per owner
-- 3. Ranks states by total FQHC count
-- 4. Provides market share percentage across all FQHCs

-- ASSUMPTIONS AND LIMITATIONS:
-- - Assumes enrollment_id and associate_id are accurate identifiers
-- - Does not account for partial ownership or complex ownership structures
-- - Snapshot of current data, does not show historical trends

-- POTENTIAL EXTENSIONS:
-- 1. Add time-based analysis using mimi_src_file_date
-- 2. Incorporate additional demographic or geographic data
-- 3. Analyze ownership patterns by provider type or incorporation date


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:26:18.142903
    - Additional Notes: Query provides a comprehensive overview of FQHC market structure, focusing on ownership distribution across states and organizational types. Limitations include snapshot-based analysis and potential complexity in ownership structures.
    
    */