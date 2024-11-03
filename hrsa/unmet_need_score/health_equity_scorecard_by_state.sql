-- Title: Geographic Health Equity Scorecard Analysis
-- 
-- Business Purpose:
-- - Identify ZIP codes where health equity indicators suggest significant disparities
-- - Understand the relationship between socioeconomic factors and health outcomes
-- - Guide equitable resource allocation and community health interventions
-- - Support health equity policy and program development decisions

WITH health_equity_metrics AS (
    -- Calculate key health equity indicators by ZIP code
    SELECT 
        zip_code,
        state,
        population_size,
        zcta_uns AS unmet_need_score,
        -- Health access indicators
        uninsured,
        health_center_penetration,
        -- Socioeconomic indicators
        below_poverty_level,
        linguistic_isolation,
        no_vehicle_access,
        -- Health outcome indicators
        life_expectancy,
        preventable_hospital_stays
    FROM mimi_ws_1.hrsa.unmet_need_score
    WHERE population_size > 1000  -- Focus on populated areas
),

ranked_zips AS (
    -- Rank ZIP codes based on combined equity factors
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY unmet_need_score DESC) AS uns_quintile,
        NTILE(5) OVER (ORDER BY uninsured DESC) AS uninsured_quintile,
        NTILE(5) OVER (ORDER BY below_poverty_level DESC) AS poverty_quintile
    FROM health_equity_metrics
)

-- Generate final health equity scorecard
SELECT 
    state,
    COUNT(DISTINCT zip_code) as total_zips,
    ROUND(AVG(unmet_need_score), 2) as avg_unmet_need_score,
    ROUND(AVG(life_expectancy), 1) as avg_life_expectancy,
    ROUND(AVG(uninsured * 100), 1) as avg_uninsured_pct,
    ROUND(AVG(below_poverty_level * 100), 1) as avg_poverty_pct,
    COUNT(CASE WHEN uns_quintile = 1 AND uninsured_quintile = 1 THEN 1 END) as high_risk_zips
FROM ranked_zips
GROUP BY state
HAVING COUNT(DISTINCT zip_code) >= 5
ORDER BY avg_unmet_need_score DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE with relevant health equity metrics filtered for populated areas
-- 2. Ranks ZIP codes using quintiles for key measures
-- 3. Aggregates results by state to create a health equity scorecard
-- 4. Identifies areas with both high unmet needs and high uninsurance rates

-- Assumptions and limitations:
-- - Requires population threshold of 1000 to avoid small area variation
-- - Uses current snapshot data only, no historical trends
-- - Equal weighting given to different factors in risk assessment
-- - State-level aggregation may mask local variations

-- Possible extensions:
-- 1. Add temporal analysis to track changes over time
-- 2. Create composite health equity index combining multiple factors
-- 3. Include geographic clustering analysis to identify regional patterns
-- 4. Add demographic breakdowns by age, race, or other factors
-- 5. Incorporate cost of living adjustments for poverty measures

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:20:14.616219
    - Additional Notes: This query provides a state-level health equity assessment focusing on population centers (>1000 residents). The scorecard combines multiple social determinants of health and access metrics to identify states with the greatest health equity challenges. The high_risk_zips count identifies areas with both high unmet needs and high uninsurance rates, making it particularly useful for policy planning and resource allocation.
    
    */