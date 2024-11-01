-- identify_age_friendly_communities.sql

-- Business Purpose:
-- - Identify communities with significant population bases that could be targets for senior services
-- - Support planning for healthcare facilities, assisted living, and community programs
-- - Enable evidence-based decisions for aging-in-place initiatives and senior-focused business opportunities

-- Main Query
WITH population_segments AS (
    -- Get population data for all ZCTAs
    SELECT 
        zcta,
        tot_population_est,
        -- Classify ZCTAs by population size
        CASE 
            WHEN tot_population_est >= 40000 THEN 'Large'
            WHEN tot_population_est >= 20000 THEN 'Medium'
            ELSE 'Small'
        END AS community_size
    FROM mimi_ws_1.census.pop_est_zcta
    WHERE year = 2020
)

SELECT 
    community_size,
    COUNT(zcta) as num_communities,
    SUM(tot_population_est) as total_population,
    ROUND(AVG(tot_population_est), 0) as avg_population,
    -- Calculate percentage of total communities
    ROUND(COUNT(zcta) * 100.0 / SUM(COUNT(zcta)) OVER (), 1) as pct_of_communities
FROM population_segments
GROUP BY community_size
ORDER BY 
    CASE community_size 
        WHEN 'Large' THEN 1 
        WHEN 'Medium' THEN 2 
        ELSE 3 
    END;

-- How it works:
-- 1. Creates a CTE that segments ZCTAs into population size categories
-- 2. Calculates key metrics for each community size segment
-- 3. Provides a summary view of population distribution across different community sizes

-- Assumptions and Limitations:
-- - Uses 2020 population data only
-- - Simple size categorization (can be adjusted based on specific needs)
-- - Does not account for geographic distribution or proximity
-- - Does not include demographic composition data

-- Possible Extensions:
-- 1. Add state-level analysis to identify regional patterns
-- 2. Include year-over-year growth analysis when historical data is available
-- 3. Incorporate geographic clustering to identify concentrated areas of similarly-sized communities
-- 4. Add filters for specific regions or population thresholds
-- 5. Create additional size categories for more granular analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:57:27.473972
    - Additional Notes: Query focuses on basic community segmentation by population size, providing a foundation for analyzing service opportunities. Consider adjusting population thresholds (40000/20000) based on specific business needs. Results can be used for initial market sizing but should be supplemented with demographic and geographic data for detailed planning.
    
    */