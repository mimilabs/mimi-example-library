-- hospice_chain_analysis.sql
-- Business Purpose: Identify and analyze hospice chains and multi-facility organizations
-- This analysis helps understand market consolidation, organizational scale, and 
-- potential operational efficiencies in the hospice industry.

WITH chain_summary AS (
    -- Group hospices by organization name to identify chains
    SELECT 
        organization_name,
        COUNT(DISTINCT enrollment_id) as facility_count,
        COUNT(DISTINCT state_owner) as states_operating,
        MAX(association_date_owner) as most_recent_acquisition,
        MIN(association_date_owner) as earliest_acquisition,
        SUM(CASE WHEN corporation_owner = 'Y' THEN 1 ELSE 0 END) as corporate_owners,
        SUM(CASE WHEN management_services_company_owner = 'Y' THEN 1 ELSE 0 END) as mgmt_service_owners
    FROM mimi_ws_1.datacmsgov.pc_hospice_owner
    WHERE organization_name IS NOT NULL
    GROUP BY organization_name
    HAVING COUNT(DISTINCT enrollment_id) > 1  -- Focus on multi-facility organizations
),

size_tiers AS (
    -- Categorize chains by size
    SELECT 
        CASE 
            WHEN facility_count >= 20 THEN 'Large Chain (20+ facilities)'
            WHEN facility_count >= 10 THEN 'Medium Chain (10-19 facilities)'
            WHEN facility_count >= 5 THEN 'Small Chain (5-9 facilities)'
            ELSE 'Mini Chain (2-4 facilities)'
        END as chain_size_category,
        COUNT(*) as number_of_chains,
        SUM(facility_count) as total_facilities,
        AVG(states_operating) as avg_states_per_chain,
        COUNT(CASE WHEN states_operating > 1 THEN 1 END) as multi_state_chains
    FROM chain_summary
    GROUP BY 
        CASE 
            WHEN facility_count >= 20 THEN 'Large Chain (20+ facilities)'
            WHEN facility_count >= 10 THEN 'Medium Chain (10-19 facilities)'
            WHEN facility_count >= 5 THEN 'Small Chain (5-9 facilities)'
            ELSE 'Mini Chain (2-4 facilities)'
        END
)

-- Final output combining key metrics
SELECT 
    chain_size_category,
    number_of_chains,
    total_facilities,
    ROUND(avg_states_per_chain, 1) as avg_states_per_chain,
    multi_state_chains,
    ROUND(100.0 * multi_state_chains / number_of_chains, 1) as pct_multi_state
FROM size_tiers
ORDER BY 
    CASE chain_size_category
        WHEN 'Large Chain (20+ facilities)' THEN 1
        WHEN 'Medium Chain (10-19 facilities)' THEN 2
        WHEN 'Small Chain (5-9 facilities)' THEN 3
        ELSE 4
    END;

-- How it works:
-- 1. First CTE identifies hospice chains by grouping facilities under the same organization name
-- 2. Calculates key metrics for each chain including facility count and geographic spread
-- 3. Second CTE categorizes chains by size and aggregates metrics within each category
-- 4. Final query presents the results in a clear, business-friendly format

-- Assumptions and limitations:
-- 1. Assumes organization_name is consistent across facilities in the same chain
-- 2. Does not account for complex ownership structures where multiple legal entities may be related
-- 3. Geographic analysis based on owner state may not reflect facility locations
-- 4. Current time period snapshot only - does not show historical trends

-- Possible extensions:
-- 1. Add year-over-year growth analysis for chains
-- 2. Include quality metrics correlation with chain size
-- 3. Analyze ownership type distribution within chains
-- 4. Add geographic concentration analysis
-- 5. Include financial metrics if available in other tables

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:22:52.185766
    - Additional Notes: Query focuses on identifying market concentration patterns by analyzing hospice chains of different sizes. Note that the facility counts may be understated if organizations operate under multiple legal names. Best used in conjunction with time series analysis to track consolidation trends.
    
    */