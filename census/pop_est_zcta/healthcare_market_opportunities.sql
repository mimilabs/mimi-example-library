-- find_high_potential_medical_market_areas.sql

-- Business Purpose:
-- - Identify ZCTAs with significant population size (>50,000) that could represent opportunities for healthcare services
-- - Help healthcare organizations prioritize market expansion based on population thresholds
-- - Support initial market assessment for medical facilities, clinics, or healthcare service locations
-- - Provide foundational data for healthcare market analysis

SELECT 
    zcta,
    tot_population_est,
    -- Create population size categories for easier analysis
    CASE 
        WHEN tot_population_est >= 100000 THEN 'Very Large Market'
        WHEN tot_population_est >= 50000 THEN 'Large Market'
        WHEN tot_population_est >= 25000 THEN 'Medium Market'
        ELSE 'Small Market'
    END as market_size_category,
    -- Calculate the percentage of very large markets
    tot_population_est / SUM(tot_population_est) OVER () * 100 as pct_of_total_population
FROM mimi_ws_1.census.pop_est_zcta
WHERE year = 2020  -- Focus on most recent census data
  AND tot_population_est >= 25000  -- Filter for meaningful market sizes
ORDER BY tot_population_est DESC
LIMIT 100;  -- Focus on top opportunities

-- How this query works:
-- 1. Filters for ZCTAs with populations over 25,000 to focus on viable markets
-- 2. Categorizes markets by population size for strategic prioritization
-- 3. Calculates each ZCTA's share of total population
-- 4. Orders results by population size to identify top opportunities
-- 5. Limits to top 100 results for practical analysis

-- Assumptions and Limitations:
-- - Assumes population size is a primary indicator of healthcare market potential
-- - Does not account for existing healthcare facilities or competition
-- - Based on 2020 census data, may not reflect current population changes
-- - ZCTA boundaries may not perfectly align with actual service areas
-- - Does not consider demographic factors like age or income

-- Possible Extensions:
-- 1. Add state/region grouping for geographic strategy
-- 2. Include year-over-year population growth analysis
-- 3. Join with healthcare facility data to identify underserved areas
-- 4. Add demographic data for more targeted analysis
-- 5. Include drive time or distance analysis for service area planning
-- 6. Factor in competition density from other healthcare providers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:40:41.649965
    - Additional Notes: Query identifies high-population ZCTAs suitable for healthcare market expansion. The 25,000 population threshold and 100-record limit are configurable parameters that can be adjusted based on specific business needs. Results provide both absolute population counts and relative market size categories for strategic decision-making.
    
    */