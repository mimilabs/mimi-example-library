-- snf_investment_ownership.sql
-- Analyzes investment-related ownership patterns in Skilled Nursing Facilities (SNFs)
-- to identify concentration of financial investment entities in the SNF sector
-- Business Purpose: Help healthcare strategists and analysts understand 
-- the penetration of investment firms and financial institutions in SNF ownership
-- for market assessment and competitive intelligence

WITH investment_owners AS (
    -- Identify owners that are investment-related entities
    SELECT 
        organization_name_owner,
        COUNT(DISTINCT enrollment_id) as facilities_owned,
        AVG(CAST(percentage_ownership AS FLOAT)) as avg_ownership_percentage,
        SUM(CASE WHEN percentage_ownership >= 50 THEN 1 ELSE 0 END) as controlling_interest_count
    FROM mimi_ws_1.datacmsgov.pc_snf_owner
    WHERE 
        -- Focus on investment-oriented ownership types
        (investment_firm_owner = 'Y' 
        OR financial_institution_owner = 'Y'
        OR holding_company_owner = 'Y')
        AND type_owner = 'O' -- Organizations only
        AND organization_name_owner IS NOT NULL
    GROUP BY organization_name_owner
    HAVING COUNT(DISTINCT enrollment_id) >= 5 -- Focus on larger players
),

ownership_summary AS (
    -- Calculate market concentration metrics
    SELECT 
        COUNT(*) as total_investment_owners,
        SUM(facilities_owned) as total_facilities_controlled,
        AVG(facilities_owned) as avg_facilities_per_owner,
        AVG(avg_ownership_percentage) as avg_ownership_stake,
        SUM(controlling_interest_count) as total_controlling_interests
    FROM investment_owners
)

SELECT 
    io.organization_name_owner,
    io.facilities_owned,
    ROUND(io.avg_ownership_percentage, 2) as avg_ownership_pct,
    io.controlling_interest_count,
    ROUND(100.0 * io.facilities_owned / os.total_facilities_controlled, 2) as market_share_pct
FROM investment_owners io
CROSS JOIN ownership_summary os
ORDER BY io.facilities_owned DESC
LIMIT 20;

-- How this query works:
-- 1. Identifies investment-related owners (investment firms, financial institutions, holding companies)
-- 2. Calculates key metrics per owner: facility count, average ownership %, controlling interests
-- 3. Generates market concentration metrics
-- 4. Presents top 20 investment-related owners with their market share

-- Assumptions and Limitations:
-- - Focuses only on explicitly marked investment-related entities
-- - Requires minimum 5 facilities for inclusion
-- - May undercount total market presence due to complex ownership structures
-- - Assumes ownership percentages are accurately reported

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Include temporal analysis using association_date_owner
-- 3. Correlate with quality metrics from other CMS datasets
-- 4. Analyze ownership changes and consolidation trends
-- 5. Include additional ownership types or lower facility count thresholds/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:16:30.139700
    - Additional Notes: Query focuses on market concentration among investment entities owning SNFs. Requires at least 5 facilities per owner for inclusion. Results are limited to top 20 investment owners by facility count. Market share calculations are relative to investment-owned facilities only, not total SNF market.
    
    */