-- Medicare Advantage Market Share Analysis by Parent Organization and State
-- 
-- Business Purpose:
-- Analyze market concentration and enrollment distribution across parent organizations
-- and states to identify market leaders and potential opportunities/risks in the
-- Medicare Advantage space. This analysis helps with:
-- - Competitive intelligence
-- - Market entry/expansion decisions
-- - Risk assessment for payer negotiations
-- - Network adequacy evaluation

WITH latest_data AS (
    -- Get the most recent data snapshot
    SELECT MAX(mimi_src_file_date) as max_date
    FROM mimi_ws_1.partcd.cpsc_combined
),

market_share AS (
    -- Calculate market share by parent org and state
    SELECT 
        state,
        parent_organization,
        SUM(enrollment) as total_enrollment,
        -- Calculate state-level metrics
        SUM(SUM(enrollment)) OVER (PARTITION BY state) as state_total_enrollment,
        SUM(enrollment) * 100.0 / SUM(SUM(enrollment)) OVER (PARTITION BY state) as state_market_share,
        -- Calculate national metrics
        SUM(SUM(enrollment)) OVER () as national_total_enrollment,
        SUM(enrollment) * 100.0 / SUM(SUM(enrollment)) OVER () as national_market_share
    FROM mimi_ws_1.partcd.cpsc_combined c
    JOIN latest_data l ON c.mimi_src_file_date = l.max_date
    WHERE parent_organization IS NOT NULL
    GROUP BY state, parent_organization
)

SELECT 
    state,
    parent_organization,
    total_enrollment,
    ROUND(state_market_share, 1) as state_market_share_pct,
    ROUND(national_market_share, 1) as national_market_share_pct,
    -- Add rank within state
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY total_enrollment DESC) as state_rank
FROM market_share
WHERE state_market_share >= 5.0  -- Focus on significant market players
ORDER BY 
    state,
    total_enrollment DESC

-- How this query works:
-- 1. Identifies the latest data snapshot to ensure currency
-- 2. Calculates enrollment totals and market share at state and national levels
-- 3. Ranks organizations within each state
-- 4. Filters to show only organizations with >= 5% state market share
--
-- Assumptions and Limitations:
-- - Uses parent_organization field for corporate relationships
-- - Assumes most recent data snapshot is most relevant
-- - Excludes null parent organizations
-- - Market share threshold of 5% may need adjustment for specific use cases
-- - Does not account for plan types or other segmentation
--
-- Possible Extensions:
-- 1. Add time-series analysis to show market share trends
-- 2. Include plan type breakdown within parent organizations
-- 3. Add geographic clustering analysis for regional patterns
-- 4. Incorporate Medicare eligibility population for penetration analysis
-- 5. Add contract counts and HHI concentration metrics
-- 6. Include SNP and EGHP segmentation for detailed market analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:16:58.105687
    - Additional Notes: Query assumes equal weighting of enrollment numbers across different plan types and does not account for seasonal enrollment variations. Market share calculations may need adjustment in territories or regions with unique Medicare Advantage regulations. The 5% threshold for market share significance should be reviewed based on specific market conditions and analysis needs.
    
    */