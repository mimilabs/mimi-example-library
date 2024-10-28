
/* 
Urban-Rural Population Distribution Analysis

Purpose: Analyze the distribution of US population across urban-rural classifications
to understand population concentration and changes over time. This information is
crucial for public health planning, resource allocation, and studying health disparities.

Business Value:
- Identifies population centers and rural areas for healthcare resource planning
- Tracks urbanization trends through classification changes
- Supports analysis of health outcome disparities across the urban-rural continuum
*/

-- Main analysis of population distribution across urban-rural categories
WITH classification_2013 AS (
  SELECT 
    CASE "2013_code"
      WHEN 1 THEN 'Large central metro'
      WHEN 2 THEN 'Large fringe metro' 
      WHEN 3 THEN 'Medium metro'
      WHEN 4 THEN 'Small metro'
      WHEN 5 THEN 'Micropolitan'
      WHEN 6 THEN 'Noncore'
    END AS urban_rural_category,
    COUNT(DISTINCT fips_code) as county_count,
    SUM(county_2012_pop) as total_population,
    ROUND(AVG(county_2012_pop),0) as avg_county_pop,
    ROUND(SUM(county_2012_pop) * 100.0 / SUM(SUM(county_2012_pop)) OVER (), 1) as pct_total_pop
  FROM mimi_ws_1.cdc.urbanrural_classification
  GROUP BY "2013_code"
  ORDER BY "2013_code"
)

SELECT 
  urban_rural_category,
  county_count,
  FORMAT_NUMBER(total_population, 0) as total_population,
  FORMAT_NUMBER(avg_county_pop, 0) as avg_county_population,
  CONCAT(pct_total_pop, '%') as percent_of_total_pop
FROM classification_2013;

/*
How this query works:
1. Creates descriptive categories from the 2013 classification codes
2. Aggregates county counts and population statistics by category
3. Calculates percentage of total population in each category
4. Formats output for readability

Assumptions & Limitations:
- Uses 2012 population data (most recent in dataset)
- Focuses on 2013 classification scheme only
- Assumes all counties have valid population data
- Does not account for geographic distribution within categories

Possible Extensions:
1. Compare classifications across years (1990, 2006, 2013) to show urbanization trends
2. Add state-level aggregations to show regional patterns
3. Include CBSA analysis for metropolitan areas
4. Add geographic clustering analysis
5. Compare population density across categories
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:36:33.129337
    - Additional Notes: Query provides county-level population analysis across urban-rural categories using 2012 population data and 2013 NCHS classification codes. Results show total population, county counts, and population distribution percentages for each urban-rural category. FORMAT_NUMBER function usage requires Databricks runtime.
    
    */