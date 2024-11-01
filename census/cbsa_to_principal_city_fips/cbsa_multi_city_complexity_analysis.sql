-- CBSA Population Centers and Growth Opportunities Analysis
-- Business Purpose: 
-- Identifies key metropolitan and micropolitan statistical areas with multiple principal cities,
-- which often indicates economic diversity and potential market opportunities.
-- This analysis helps business strategists identify regions for expansion or investment
-- by highlighting areas with distributed economic activity centers.

WITH ranked_cities AS (
  SELECT 
    cbsa_code,
    cbsa_title,
    metropolitan_micropolitan_statistical_area,
    COUNT(DISTINCT principal_city_name) as num_principal_cities,
    COLLECT_LIST(principal_city_name) as city_list
  FROM mimi_ws_1.census.cbsa_to_principal_city_fips
  GROUP BY 
    cbsa_code,
    cbsa_title,
    metropolitan_micropolitan_statistical_area
),

multi_city_areas AS (
  SELECT 
    cbsa_code,
    cbsa_title,
    metropolitan_micropolitan_statistical_area,
    num_principal_cities,
    ARRAY_JOIN(city_list, ', ') as city_list_string,
    CASE 
      WHEN num_principal_cities >= 3 THEN 'High Complexity'
      WHEN num_principal_cities = 2 THEN 'Moderate Complexity'
      ELSE 'Single Center'
    END as market_complexity
  FROM ranked_cities
  WHERE num_principal_cities > 1
)

SELECT 
  market_complexity,
  metropolitan_micropolitan_statistical_area,
  cbsa_title,
  num_principal_cities,
  city_list_string
FROM multi_city_areas
ORDER BY 
  num_principal_cities DESC,
  cbsa_title
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates principal cities by CBSA using COLLECT_LIST
-- 2. Second CTE filters for multi-city areas, joins array elements, and adds complexity classification
-- 3. Final query presents results sorted by number of principal cities

-- Assumptions and Limitations:
-- - Assumes current CBSA definitions are up-to-date
-- - Multiple principal cities indicate economic diversity (may not always be true)
-- - Limited to top 20 results for manageability
-- - Does not account for population size or economic indicators

-- Possible Extensions:
-- 1. Add population data to weight the analysis
-- 2. Include year-over-year change analysis
-- 3. Add economic indicators (GDP, employment) for each CBSA
-- 4. Create regional groupings for geographic distribution analysis
-- 5. Include distance calculations between principal cities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:39:18.061623
    - Additional Notes: Query focuses on identifying economic complexity through multiple principal cities in CBSAs. The COLLECT_LIST and ARRAY_JOIN functions are Databricks-specific. Results are capped at 20 records for performance and readability. Market complexity classification is based on number of principal cities (3+ = High, 2 = Moderate).
    
    */