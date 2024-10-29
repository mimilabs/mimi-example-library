-- Medicare Hospice Chain Analysis - Network Identification and Scale
-- 
-- Business Purpose: Identify large hospice networks and chains to understand market 
-- consolidation and corporate ownership patterns. This helps with:
-- - Evaluating potential M&A targets
-- - Understanding network effects and economies of scale
-- - Assessing market concentration risks
-- - Identifying strategic expansion opportunities

WITH chain_metrics AS (
    -- Group hospices by organization name to identify potential chains/networks
    SELECT 
        organization_name,
        COUNT(DISTINCT ccn) as facility_count,
        COUNT(DISTINCT state) as state_count,
        COLLECT_SET(state) as states_present,
        COUNT(DISTINCT zip_code) as unique_locations,
        proprietary_nonprofit as ownership_type
    FROM mimi_ws_1.datacmsgov.pc_hospice
    WHERE organization_name IS NOT NULL
    GROUP BY organization_name, proprietary_nonprofit
),

ranked_chains AS (
    -- Rank chains by size and add classification
    SELECT 
        *,
        CASE 
            WHEN facility_count >= 10 THEN 'Large Chain'
            WHEN facility_count >= 5 THEN 'Mid-size Chain'
            ELSE 'Small Operator'
        END as chain_classification
    FROM chain_metrics
    WHERE facility_count > 1  -- Focus on multi-facility organizations
)

SELECT 
    chain_classification,
    ownership_type,
    COUNT(*) as chain_count,
    SUM(facility_count) as total_facilities,
    ROUND(AVG(state_count), 1) as avg_states_per_chain,
    ROUND(AVG(facility_count), 1) as avg_facilities_per_chain
FROM ranked_chains
GROUP BY chain_classification, ownership_type
ORDER BY 
    CASE chain_classification 
        WHEN 'Large Chain' THEN 1 
        WHEN 'Mid-size Chain' THEN 2 
        ELSE 3 
    END,
    ownership_type;

-- How this query works:
-- 1. First CTE aggregates hospice facilities by organization name to identify chains
-- 2. Second CTE classifies chains by size and filters for multi-facility organizations
-- 3. Final query summarizes chain characteristics by classification and ownership type

-- Assumptions & Limitations:
-- - Organizations are identified solely by name (may miss some affiliated entities)
-- - Assumes current snapshot data (doesn't capture historical changes)
-- - Chain classification thresholds are somewhat arbitrary
-- - Does not account for parent company relationships or complex ownership structures

-- Possible Extensions:
-- 1. Add year-over-year growth analysis by incorporating historical data
-- 2. Include geographic concentration metrics (HHI by state/region)
-- 3. Link to owner table to identify ultimate parent companies
-- 4. Add financial metrics if available (revenue, profitability)
-- 5. Create market share analysis at state/regional level
-- 6. Incorporate quality metrics to assess relationship between scale and performance

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:38:09.780883
    - Additional Notes: This query categorizes hospice organizations into chain size tiers (Large/Mid-size/Small) and compares their operational scale across ownership types. The states_present field uses COLLECT_SET which returns an array of unique states, useful for detailed geographic footprint analysis. Results can help identify market consolidation patterns and potential acquisition targets.
    
    */