-- Network Analysis of Excluded Healthcare Entities
-- Business Purpose: 
-- Identifies potential relationships between excluded healthcare providers and entities
-- by analyzing co-occurrences at the same addresses and business names.
-- This helps identify potential networks of fraud or abuse and high-risk addresses/organizations.

WITH base_data AS (
    -- Get valid business entities and addresses, excluding missing data
    SELECT 
        COALESCE(busname, CONCAT(lastname, ' ', firstname)) as entity_name,
        address,
        city,
        state,
        excldate,
        npi
    FROM mimi_ws_1.hhsoig.leie
    WHERE address IS NOT NULL 
    AND state IS NOT NULL
),

address_grouping AS (
    -- Find addresses with multiple excluded entities
    SELECT 
        address,
        city,
        state,
        COUNT(DISTINCT entity_name) as entities_at_address,
        COUNT(DISTINCT npi) as unique_npis,
        MIN(excldate) as first_exclusion,
        MAX(excldate) as latest_exclusion,
        CONCAT_WS('; ', COLLECT_SET(entity_name)) as related_entities
    FROM base_data
    GROUP BY address, city, state
    HAVING COUNT(DISTINCT entity_name) > 1
),

summary_stats AS (
    -- Calculate summary statistics
    SELECT 
        state,
        COUNT(DISTINCT address) as high_risk_addresses,
        SUM(entities_at_address) as total_related_entities,
        AVG(entities_at_address) as avg_entities_per_address,
        MAX(entities_at_address) as max_entities_at_address
    FROM address_grouping
    GROUP BY state
)

SELECT 
    s.state,
    s.high_risk_addresses,
    s.total_related_entities,
    ROUND(s.avg_entities_per_address, 2) as avg_entities_per_address,
    s.max_entities_at_address,
    a.address,
    a.city,
    a.entities_at_address,
    a.first_exclusion,
    a.latest_exclusion,
    a.related_entities
FROM summary_stats s
LEFT JOIN address_grouping a 
    ON s.state = a.state
WHERE s.high_risk_addresses >= 3
ORDER BY s.high_risk_addresses DESC, a.entities_at_address DESC;

-- How it works:
-- 1. Creates a clean base dataset of entities and their locations
-- 2. Groups by address to find locations with multiple excluded entities
-- 3. Calculates state-level statistics about these groupings
-- 4. Joins summary stats with detailed address data for drill-down analysis

-- Assumptions and limitations:
-- - Assumes address data is standardized and accurate
-- - Does not account for minor address variations
-- - Limited to current exclusions only
-- - May include legitimate business co-locations
-- - Does not verify actual relationships between entities

-- Possible extensions:
-- 1. Add temporal analysis to identify patterns over time
-- 2. Include exclusion types and reasons in the network analysis
-- 3. Implement address standardization and fuzzy matching
-- 4. Add geographic clustering analysis
-- 5. Include business name similarity analysis
-- 6. Add risk scoring based on various factors
-- 7. Extend to analyze chains of related addresses through common entities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:34:42.843774
    - Additional Notes: Query identifies potential fraud networks by analyzing addresses with multiple excluded healthcare providers. Results are grouped by state and show detailed information about high-risk locations with 3 or more excluded entities. The address-based clustering may need refinement to account for large medical buildings or complexes that legitimately house multiple providers.
    
    */