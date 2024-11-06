-- Healthcare_Organization_Concentration_Metrics.sql

-- Business Purpose:
-- - Calculate the density and concentration of healthcare organizations in each city
-- - Identify potential over-served and under-served markets
-- - Guide market entry and expansion decisions
-- - Support competitive analysis and strategic planning

WITH org_metrics AS (
    -- Calculate organization counts and average metrics by city
    SELECT 
        city,
        state,
        COUNT(*) as org_count,
        ROUND(AVG(revenue), 2) as avg_revenue,
        ROUND(AVG(utilization), 2) as avg_utilization,
        COUNT(*) * 1.0 / SUM(COUNT(*)) OVER(PARTITION BY state) as city_concentration_ratio
    FROM mimi_ws_1.synthea.organizations
    GROUP BY city, state
),
city_rankings AS (
    -- Rank cities within each state by organization count
    SELECT 
        *,
        RANK() OVER(PARTITION BY state ORDER BY org_count DESC) as rank_in_state
    FROM org_metrics
)
SELECT 
    city,
    state,
    org_count,
    avg_revenue,
    avg_utilization,
    ROUND(city_concentration_ratio * 100, 2) as market_share_pct,
    rank_in_state
FROM city_rankings
WHERE rank_in_state <= 5  -- Focus on top 5 cities per state
ORDER BY state, rank_in_state;

-- How the Query Works:
-- 1. First CTE aggregates organization data by city
-- 2. Second CTE adds rankings within each state
-- 3. Final output shows top 5 cities per state with key metrics
-- 4. Concentration ratio shows what percentage of state's organizations are in each city

-- Assumptions and Limitations:
-- - Assumes organization distribution correlates with population/demand
-- - Does not account for organization size/capacity differences
-- - City boundaries may not reflect true service areas
-- - Synthetic data may not perfectly mirror real-world patterns

-- Possible Extensions:
-- 1. Add population data to calculate per-capita metrics
-- 2. Include distance calculations between organizations
-- 3. Add year-over-year growth metrics
-- 4. Incorporate specialty/service line analysis
-- 5. Add competitive intensity metrics based on proximity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:24:28.461833
    - Additional Notes: Query focuses on market concentration metrics but may need to be combined with demographic data for more accurate market analysis. Consider adjusting the top N cities threshold (currently set to 5) based on specific analysis needs.
    
    */