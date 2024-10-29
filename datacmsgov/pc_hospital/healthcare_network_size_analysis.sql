-- Hospital Network Affiliation Analysis
-- 
-- Business Purpose:
-- - Identify hospitals operating under shared business names to map healthcare networks
-- - Analyze market consolidation patterns through common organizational names
-- - Support strategic analysis of healthcare system partnerships and affiliations
-- - Enable market entry and competitive landscape assessment

WITH organization_grouping AS (
    -- Aggregate hospitals under shared business names
    SELECT 
        organization_name,
        COUNT(DISTINCT enrollment_id) as total_facilities,
        COUNT(DISTINCT state) as states_present,
        -- Using collect_set instead of STRING_AGG for Databricks SQL
        ARRAY_JOIN(COLLECT_SET(state), ', ') as state_list,
        COUNT(DISTINCT ccn) as unique_ccns,
        SUM(CASE WHEN proprietary_nonprofit = 'P' THEN 1 ELSE 0 END) as for_profit_count,
        SUM(CASE WHEN proprietary_nonprofit = 'N' THEN 1 ELSE 0 END) as non_profit_count
    FROM mimi_ws_1.datacmsgov.pc_hospital
    WHERE organization_name IS NOT NULL
    GROUP BY organization_name
    HAVING COUNT(DISTINCT enrollment_id) > 1
),

ranked_networks AS (
    -- Rank healthcare networks by size
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY total_facilities DESC) as network_rank
    FROM organization_grouping
)

-- Output top healthcare networks with key metrics
SELECT 
    network_rank,
    organization_name,
    total_facilities,
    states_present,
    state_list,
    unique_ccns,
    for_profit_count,
    non_profit_count,
    ROUND(for_profit_count * 100.0 / total_facilities, 1) as for_profit_percentage
FROM ranked_networks
WHERE network_rank <= 20
ORDER BY total_facilities DESC;

-- How this query works:
-- 1. First CTE groups hospitals by organization name and calculates key metrics
-- 2. Second CTE ranks organizations by facility count
-- 3. Final output shows top 20 healthcare networks with detailed metrics
--
-- Assumptions:
-- - Organizations sharing the same exact name are part of the same network
-- - Multiple enrollment IDs under same organization represent distinct facilities
-- - Non-null organization names represent valid business entities
--
-- Limitations:
-- - May miss networks using variant names or DBAs
-- - Does not account for parent-subsidiary relationships
-- - Point-in-time snapshot based on current Medicare enrollment
--
-- Possible Extensions:
-- - Include DBA name analysis for additional network identification
-- - Add facility type distribution within networks
-- - Incorporate geographic clustering analysis
-- - Add time-based trend analysis using historical data
-- - Include size metrics like bed counts if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:16:01.815335
    - Additional Notes: Query identifies major healthcare networks based on shared organizational names and provides insights into their geographic spread and ownership structure. Data quality depends heavily on consistent organization name reporting. Network size is measured by facility count rather than bed capacity or revenue, which may not fully represent actual market presence.
    
    */