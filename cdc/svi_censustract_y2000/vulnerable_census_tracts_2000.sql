
/* 
Census Tract Social Vulnerability Analysis for Emergency Preparedness (2000)

Business Purpose:
This query identifies the most vulnerable census tracts based on the CDC's Social 
Vulnerability Index (SVI) to help emergency planners and public health officials:
- Target resources to communities that need the most support
- Prepare for effective disaster response
- Allocate emergency preparedness funding
*/

WITH vulnerability_metrics AS (
  -- Calculate key vulnerability indicators per census tract
  SELECT 
    state_name,
    county,
    tract,
    -- Overall vulnerability score
    ustp as total_vulnerability_percentile,
    
    -- Core vulnerability factors (raw proportions)
    g1v1r as poverty_rate,
    g1v2r as unemployment_rate,
    g2v3r as disability_rate,
    g3v1r as minority_rate,
    g4v4r as no_vehicle_rate,
    
    -- Population context
    totpop2000 as total_population
  FROM mimi_ws_1.cdc.svi_censustract_y2000
)

SELECT
  state_name,
  county,
  -- Identify highly vulnerable tracts
  COUNT(*) as total_tracts,
  COUNT(CASE WHEN total_vulnerability_percentile >= 90 THEN 1 END) as high_vulnerability_tracts,
  
  -- Calculate average vulnerability metrics
  ROUND(AVG(poverty_rate)*100,1) as avg_poverty_pct,
  ROUND(AVG(unemployment_rate)*100,1) as avg_unemployment_pct,
  ROUND(AVG(disability_rate)*100,1) as avg_disability_pct,
  ROUND(AVG(minority_rate)*100,1) as avg_minority_pct,
  ROUND(AVG(no_vehicle_rate)*100,1) as avg_no_vehicle_pct,
  
  -- Total population affected
  SUM(total_population) as total_population
FROM vulnerability_metrics
GROUP BY state_name, county
HAVING COUNT(CASE WHEN total_vulnerability_percentile >= 90 THEN 1 END) > 0
ORDER BY high_vulnerability_tracts DESC
LIMIT 20;

/*
HOW IT WORKS:
1. Creates a CTE with key vulnerability metrics at the census tract level
2. Aggregates to county level to identify areas with concentrations of vulnerable tracts
3. Filters to show only counties with at least one highly vulnerable tract
4. Orders by number of vulnerable tracts to highlight priority areas

ASSUMPTIONS & LIMITATIONS:
- Uses 90th percentile as threshold for "highly vulnerable"
- Based on 2000 data which may not reflect current conditions
- Treats all vulnerability factors with equal weight
- Does not account for geographic proximity of vulnerable tracts

POSSIBLE EXTENSIONS:
1. Add geographic clustering analysis to identify vulnerable regions
2. Compare vulnerability patterns across different years
3. Incorporate specific hazard exposure data
4. Calculate vulnerability-weighted population metrics
5. Add demographic breakdowns of vulnerable populations
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:05:49.572272
    - Additional Notes: The query provides county-level summary statistics for social vulnerability, focusing on counties with at least one highly vulnerable census tract (90th percentile or above). Results are limited to top 20 counties by number of vulnerable tracts. Key metrics include poverty, unemployment, disability, minority population, and vehicle access rates.
    
    */