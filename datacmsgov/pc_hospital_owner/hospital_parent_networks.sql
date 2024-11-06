-- hospital_parent_companies.sql

-- Business Purpose: 
-- This query identifies the major parent companies and investment entities controlling hospitals
-- to understand consolidation patterns and corporate ownership influence in healthcare delivery.
-- Key insights include:
-- - Top parent organizations by number of hospitals controlled
-- - Investment firm and holding company presence in hospital ownership
-- - Geographic footprint of major healthcare parent companies

WITH parent_orgs AS (
    -- Focus on organizational owners that are likely parent companies
    SELECT DISTINCT
        organization_name_owner,
        COUNT(DISTINCT enrollment_id) as hospitals_controlled,
        COUNT(DISTINCT state_owner) as states_present,
        SUM(CASE WHEN holding_company_owner = 'Y' THEN 1 ELSE 0 END) as is_holding_company,
        SUM(CASE WHEN investment_firm_owner = 'Y' THEN 1 ELSE 0 END) as is_investment_firm,
        SUM(CASE WHEN for_profit_owner = 'Y' THEN 1 ELSE 0 END) as is_for_profit,
        AVG(CAST(percentage_ownership AS FLOAT)) as avg_ownership_stake
    FROM mimi_ws_1.datacmsgov.pc_hospital_owner
    WHERE type_owner = 'O'  -- Only organizational owners
        AND organization_name_owner IS NOT NULL
        AND percentage_ownership IS NOT NULL
    GROUP BY organization_name_owner
    HAVING COUNT(DISTINCT enrollment_id) >= 5  -- Focus on organizations controlling multiple hospitals
)

SELECT 
    organization_name_owner as parent_company,
    hospitals_controlled,
    states_present,
    ROUND(avg_ownership_stake, 2) as avg_ownership_percentage,
    CASE 
        WHEN is_holding_company > 0 THEN 'Holding Company'
        WHEN is_investment_firm > 0 THEN 'Investment Firm'
        WHEN is_for_profit > 0 THEN 'For-Profit Organization'
        ELSE 'Other Organization'
    END as ownership_category
FROM parent_orgs
ORDER BY hospitals_controlled DESC
LIMIT 50;

-- How it works:
-- 1. Creates a CTE to aggregate ownership data at the parent organization level
-- 2. Counts hospitals controlled and geographic presence
-- 3. Identifies ownership type based on reported flags
-- 4. Filters for significant parent organizations (5+ hospitals)
-- 5. Returns top 50 parent companies by hospitals controlled

-- Assumptions and limitations:
-- - Organizations are uniquely identified by organization_name_owner
-- - Minimum threshold of 5 hospitals may exclude some relevant smaller networks
-- - Ownership percentages are reported accurately
-- - Current snapshot view (temporal analysis would require date handling)

-- Possible extensions:
-- 1. Add year-over-year ownership changes by including mimi_src_file_date
-- 2. Include additional metrics like average hospital size or revenue
-- 3. Add geographic concentration analysis
-- 4. Compare financial institution vs. healthcare operator ownership patterns
-- 5. Analyze ownership stake thresholds and control patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:27:49.674304
    - Additional Notes: Query focuses on major healthcare networks and institutional ownership patterns. Note that the 5-hospital threshold for parent organizations may need adjustment based on market size. Organization names should be validated as there could be variations in naming conventions affecting the grouping logic.
    
    */