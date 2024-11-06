-- Title: Housing Stability Risk Analysis for Population Health Management - 2018

-- Business Purpose:
-- Identifies census tracts with significant housing instability risks that could impact healthcare
-- delivery and population health outcomes. This analysis helps healthcare organizations:
-- 1. Target care management programs for populations with unstable housing
-- 2. Plan community outreach and intervention strategies
-- 3. Inform decisions about mobile health services and transportation support
-- 4. Develop partnerships with community organizations for housing assistance

WITH housing_risk_metrics AS (
    -- Calculate composite housing risk score and filter to significant risk areas
    SELECT
        state,
        county,
        location,
        e_totpop as total_population,
        -- Housing instability indicators
        ep_mobile as pct_mobile_homes,
        ep_crowd as pct_crowded_housing,
        ep_noveh as pct_no_vehicle,
        -- Calculate weighted risk score
        (ep_mobile + ep_crowd * 2 + ep_noveh * 1.5) / 4.5 as housing_risk_score,
        -- Include relevant socioeconomic context
        ep_pov as pct_poverty,
        ep_uninsur as pct_uninsured
    FROM mimi_ws_1.cdc.svi_censustract_y2018
    WHERE e_totpop >= 100  -- Focus on populated areas
)

SELECT
    state,
    county,
    -- Aggregate to county level for actionable insights
    COUNT(*) as high_risk_tracts,
    SUM(total_population) as affected_population,
    ROUND(AVG(housing_risk_score), 2) as avg_housing_risk_score,
    ROUND(AVG(pct_uninsured), 1) as avg_pct_uninsured,
    ROUND(AVG(pct_poverty), 1) as avg_pct_poverty
FROM housing_risk_metrics
WHERE housing_risk_score >= 25  -- Focus on highest risk areas
GROUP BY state, county
HAVING high_risk_tracts >= 3    -- Focus on counties with multiple high-risk tracts
ORDER BY avg_housing_risk_score DESC, affected_population DESC
LIMIT 100;

-- How this query works:
-- 1. Creates a CTE that calculates a composite housing risk score from multiple indicators
-- 2. Filters for meaningful population size at tract level
-- 3. Aggregates results to county level for more actionable insights
-- 4. Includes context of insurance status and poverty
-- 5. Focuses on counties with multiple high-risk tracts to identify systematic issues

-- Assumptions and Limitations:
-- - Weights in risk score calculation are based on general impact assessment
-- - Minimum population threshold of 100 may exclude some rural areas
-- - Does not account for temporal changes in housing status
-- - County-level aggregation may mask significant tract-level variations

-- Possible Extensions:
-- 1. Add temporal analysis by comparing with previous years' data
-- 2. Include healthcare facility proximity analysis
-- 3. Incorporate local housing cost data for affordability analysis
-- 4. Add demographic breakdowns of affected populations
-- 5. Create risk tiers for more nuanced intervention planning
-- 6. Add correlation analysis with health outcomes data
-- 7. Include analysis of nearby support services and resources

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:27:59.428768
    - Additional Notes: Query identifies counties with concentrated housing instability issues by creating a weighted risk score from mobile homes, crowded housing, and vehicle access metrics. The 25% threshold for high-risk areas and minimum of 3 tracts per county may need adjustment based on local conditions and organizational priorities.
    
    */