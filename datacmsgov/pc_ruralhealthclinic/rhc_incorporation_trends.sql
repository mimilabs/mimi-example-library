-- rhc_temporal_market_trends.sql

-- Business Purpose:
-- This query analyzes the growth and establishment patterns of Rural Health Clinics (RHCs)
-- over time to understand:
-- - Market entry timing and incorporation trends
-- - Temporal patterns in RHC establishment that may indicate market maturity
-- - Planning windows for new RHC development
-- This information helps healthcare organizations and investors make strategic decisions
-- about market entry timing and location selection.

WITH monthly_incorporations AS (
    -- Aggregate incorporations by month to identify patterns
    SELECT 
        DATE_TRUNC('month', incorporation_date) as incorporation_month,
        state,
        organization_type_structure,
        proprietary_nonprofit,
        COUNT(*) as new_rhcs,
        COUNT(CASE WHEN proprietary_nonprofit = 'P' THEN 1 END) as new_proprietary,
        COUNT(CASE WHEN proprietary_nonprofit = 'N' THEN 1 END) as new_nonprofit
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic
    WHERE incorporation_date IS NOT NULL
    GROUP BY 1, 2, 3, 4
),

rolling_growth AS (
    -- Calculate 12-month rolling averages to smooth seasonal variations
    SELECT 
        incorporation_month,
        state,
        SUM(new_rhcs) OVER (
            PARTITION BY state 
            ORDER BY incorporation_month 
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) as rolling_12month_new_rhcs
    FROM monthly_incorporations
)

SELECT 
    rg.incorporation_month,
    rg.state,
    rg.rolling_12month_new_rhcs,
    mi.organization_type_structure,
    mi.new_proprietary,
    mi.new_nonprofit,
    -- Calculate market momentum indicators
    LAG(rg.rolling_12month_new_rhcs, 12) OVER (
        PARTITION BY rg.state 
        ORDER BY rg.incorporation_month
    ) as prior_year_growth,
    CASE 
        WHEN rg.rolling_12month_new_rhcs > LAG(rg.rolling_12month_new_rhcs, 12) OVER (
            PARTITION BY rg.state 
            ORDER BY rg.incorporation_month
        ) THEN 'Accelerating'
        ELSE 'Decelerating'
    END as market_momentum
FROM rolling_growth rg
JOIN monthly_incorporations mi 
    ON rg.incorporation_month = mi.incorporation_month 
    AND rg.state = mi.state
WHERE rg.incorporation_month >= '2010-01-01'
ORDER BY rg.incorporation_month DESC, rg.state;

-- How it works:
-- 1. Creates monthly aggregations of new RHC incorporations
-- 2. Calculates 12-month rolling averages to identify trends
-- 3. Compares current growth to prior year to determine market momentum
-- 4. Segments analysis by state and organization type

-- Assumptions and Limitations:
-- - Incorporation date is a reliable proxy for market entry
-- - Missing incorporation dates are excluded from analysis
-- - Analysis starts from 2010 to focus on recent market dynamics
-- - Seasonal variations are smoothed using 12-month rolling averages

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify hot spots of RHC development
-- 2. Include population demographics to normalize growth rates
-- 3. Incorporate financial performance metrics when available
-- 4. Add predictive analytics for future market opportunities
-- 5. Include competitive density analysis for market saturation assessment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:32:01.490415
    - Additional Notes: The query focuses on temporal market analysis of RHC establishments, providing insights into growth patterns and market maturity across different states. The rolling 12-month average calculation requires at least 12 months of data per state for meaningful results. States with sparse data may show incomplete trend lines.
    
    */