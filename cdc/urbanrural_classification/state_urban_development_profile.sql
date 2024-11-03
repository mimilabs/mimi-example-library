-- State-Level Urban Development Profile Analysis
--
-- Business Purpose:
-- Analyze the urban development characteristics at the state level to identify 
-- states with diverse urban-rural compositions. This information helps healthcare
-- organizations and policymakers understand market opportunities and resource 
-- allocation needs across different state environments.

-- Main Query
WITH state_metrics AS (
    SELECT 
        state_abr,
        COUNT(*) as total_counties,
        -- Calculate counties by urban-rural classification
        COUNT(CASE WHEN 2013_code = 1 THEN 1 END) as large_central_metro_counties,
        COUNT(CASE WHEN 2013_code = 2 THEN 1 END) as large_fringe_metro_counties,
        COUNT(CASE WHEN 2013_code IN (3,4) THEN 1 END) as other_metro_counties,
        COUNT(CASE WHEN 2013_code IN (5,6) THEN 1 END) as rural_counties,
        -- Calculate total population
        SUM(county_2012_pop) as total_state_pop
    FROM mimi_ws_1.cdc.urbanrural_classification
    GROUP BY state_abr
)

SELECT 
    state_abr,
    total_counties,
    -- Calculate percentages for each category
    ROUND(100.0 * large_central_metro_counties / total_counties, 1) as pct_large_central_metro,
    ROUND(100.0 * large_fringe_metro_counties / total_counties, 1) as pct_large_fringe_metro,
    ROUND(100.0 * other_metro_counties / total_counties, 1) as pct_other_metro,
    ROUND(100.0 * rural_counties / total_counties, 1) as pct_rural,
    total_state_pop,
    -- Calculate development diversity score
    ROUND(
        (large_central_metro_counties * 4 + 
         large_fringe_metro_counties * 3 + 
         other_metro_counties * 2 + 
         rural_counties * 1) / CAST(total_counties as FLOAT), 
    1) as development_score
FROM state_metrics
ORDER BY development_score DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate county-level data to state level
-- 2. Calculates the number of counties in each urban-rural category
-- 3. Computes percentages of each category
-- 4. Creates a weighted development score (higher score = more urbanized)
-- 5. Orders results by development score to identify states with varying levels of urbanization

-- Assumptions and Limitations:
-- 1. Uses 2013 classification codes as they are the most recent
-- 2. Assumes equal importance of county counts (not weighted by population)
-- 3. Development score is a simplified metric and should be used directionally
-- 4. Population data is from 2012 and may not reflect current demographics

-- Possible Extensions:
-- 1. Add year-over-year comparison using 1990 and 2006 classifications
-- 2. Include population density calculations
-- 3. Create tiers/categories of states based on development patterns
-- 4. Add geographic region groupings for regional analysis
-- 5. Include adjacent state analysis for market expansion planning

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:07:35.890641
    - Additional Notes: The query creates a composite urban development profile for each state using a weighted scoring system. The development score ranges from 1-4, where higher scores indicate more urbanized states. The scoring system weights large central metro areas most heavily (4x) down to rural areas (1x), providing a single metric for comparing state urbanization levels.
    
    */