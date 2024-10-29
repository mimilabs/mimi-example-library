-- Title: SNF Chain Affiliation and Multi-Facility Ownership Analysis

-- Business Purpose: 
-- This analysis identifies potential healthcare system affiliations and multi-facility
-- ownership patterns among Skilled Nursing Facilities (SNFs) to understand:
-- 1. The extent of chain ownership and system affiliations in the SNF market
-- 2. Geographic footprint of affiliated SNF groups
-- 3. Market concentration patterns of large SNF operators
-- This information is valuable for:
--   - Healthcare investors evaluating market opportunities
--   - Policy makers assessing market competition
--   - Healthcare systems planning network strategies

WITH affiliated_snfs AS (
    -- Identify SNFs that are part of larger systems/chains
    SELECT 
        affiliation_entity_name,
        COUNT(DISTINCT enrollment_id) as facility_count,
        COUNT(DISTINCT state) as state_presence,
        CONCAT_WS(',', COLLECT_SET(DISTINCT state)) as states_operating,
        SUM(CASE WHEN proprietary_nonprofit = 'P' THEN 1 ELSE 0 END) as for_profit_count
    FROM mimi_ws_1.datacmsgov.pc_snf
    WHERE affiliation_entity_name IS NOT NULL
    GROUP BY affiliation_entity_name
    HAVING COUNT(DISTINCT enrollment_id) > 1
),

-- Calculate market statistics
market_stats AS (
    SELECT
        COUNT(DISTINCT enrollment_id) as total_facilities,
        COUNT(DISTINCT affiliation_entity_name) as total_chains
    FROM mimi_ws_1.datacmsgov.pc_snf
    WHERE affiliation_entity_name IS NOT NULL
)

-- Final output combining chain analysis with market context
SELECT 
    a.affiliation_entity_name as chain_name,
    a.facility_count,
    a.state_presence,
    a.states_operating,
    a.for_profit_count,
    ROUND(100.0 * a.facility_count / m.total_facilities, 2) as market_share_pct,
    ROUND(100.0 * a.state_presence / 51.0, 2) as geographic_coverage_pct
FROM affiliated_snfs a
CROSS JOIN market_stats m
WHERE a.facility_count >= 5  -- Focus on larger chains
ORDER BY a.facility_count DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE identifies affiliated SNF groups and their key metrics
-- 2. Second CTE calculates overall market statistics
-- 3. Final query combines the data to show market concentration
-- 4. Results are filtered to focus on larger chains and limited to top 20

-- Assumptions and Limitations:
-- 1. Assumes affiliation_entity_name accurately represents chain ownership
-- 2. Does not capture informal or complex ownership structures
-- 3. Geographic coverage calculation assumes 51 possible states (including DC)
-- 4. Point-in-time analysis based on current enrollment data

-- Possible Extensions:
-- 1. Add year-over-year trend analysis using mimi_src_file_date
-- 2. Include additional facility characteristics (bed count, ratings)
-- 3. Add geographic clustering analysis
-- 4. Compare chain vs independent facility performance metrics
-- 5. Analyze patterns in organization_type_structure by chain

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:34:09.885184
    - Additional Notes: The query provides insights into market concentration of SNF chains. Note that the results are limited to entities with affiliation_entity_name populated and having 5 or more facilities. The geographic coverage calculation uses 51 as denominator to account for all US states plus DC. COLLECT_SET function is used for state aggregation which may return states in non-alphabetical order.
    
    */