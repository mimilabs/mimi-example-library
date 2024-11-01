-- home_health_ownership_consolidation.sql
--
-- Analyzes ownership concentration in home health agencies by identifying organizations
-- that own multiple agencies and their geographic spread. This analysis helps:
-- - Understand market consolidation trends
-- - Identify major players in the home health space
-- - Assess geographic footprint of large ownership groups
-- - Support antitrust and competition analysis
--
-- Created by: AI Assistant
-- Created on: 2024-02-13

WITH owner_metrics AS (
    -- Get unique organization owners and count their agencies
    SELECT DISTINCT
        organization_name_owner,
        COUNT(DISTINCT enrollment_id) as num_agencies,
        COUNT(DISTINCT state_owner) as num_states,
        ROUND(AVG(percentage_ownership), 2) as avg_ownership_pct,
        SUM(CASE WHEN percentage_ownership >= 50 THEN 1 ELSE 0 END) as majority_owned_count
    FROM mimi_ws_1.datacmsgov.pc_homehealth_owner
    WHERE 
        -- Focus on organizational owners with valid names
        type_owner = 'O' 
        AND organization_name_owner IS NOT NULL
    GROUP BY organization_name_owner
),

ranked_owners AS (
    -- Rank owners by number of agencies controlled
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY num_agencies DESC) as owner_rank
    FROM owner_metrics
    WHERE num_agencies > 1  -- Only include multi-agency owners
)

SELECT
    owner_rank,
    organization_name_owner as owner_organization,
    num_agencies,
    num_states as states_present,
    avg_ownership_pct as avg_ownership_percentage,
    majority_owned_count as majority_controlled_agencies
FROM ranked_owners
WHERE owner_rank <= 20  -- Show top 20 owners
ORDER BY num_agencies DESC;

-- How this query works:
-- 1. First CTE aggregates ownership data by organization
-- 2. Second CTE ranks owners by agency count
-- 3. Final output shows top 20 organizations with multiple agencies
--
-- Assumptions:
-- - Organization names are consistent across records
-- - Ownership percentage reflects actual control
-- - Current snapshot represents typical ownership patterns
--
-- Limitations:
-- - Doesn't account for parent-subsidiary relationships
-- - May miss complex ownership structures
-- - Point-in-time analysis only
--
-- Possible extensions:
-- 1. Add year-over-year ownership change analysis
-- 2. Include financial metrics for owned agencies
-- 3. Add geographic clustering analysis
-- 4. Incorporate ownership type (for-profit/non-profit) analysis
-- 5. Add patient outcome metrics correlation

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:23:21.020735
    - Additional Notes: Query identifies market concentration by analyzing organizations owning multiple home health agencies. Best used for antitrust research and market competition analysis. Note that ownership percentages below 5% may be excluded from source data, which could affect concentration calculations.
    
    */