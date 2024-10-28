
/* 
Health System Analysis - Core Metrics Overview
============================================

Business Purpose:
This query provides key metrics about U.S. health systems to understand their:
- Geographic distribution
- Size and capacity (physicians, hospitals, beds)
- Teaching status and special services
- Financial characteristics

The insights help stakeholders make decisions about:
- Healthcare access and resource allocation
- Medical education planning
- Healthcare policy and program implementation
*/

-- Main Analysis Query
WITH system_stats AS (
  SELECT 
    -- Geographic grouping
    health_sys_state,
    COUNT(DISTINCT health_sys_id) as num_systems,
    
    -- Size metrics
    AVG(total_mds) as avg_physicians,
    AVG(hosp_cnt) as avg_hospitals,
    AVG(sys_beds) as avg_beds,
    
    -- Teaching & special services
    SUM(CASE WHEN sys_teachint = 2 THEN 1 ELSE 0 END) as major_teaching_systems,
    SUM(CASE WHEN deg_children > 0 THEN 1 ELSE 0 END) as systems_with_childrens,
    
    -- Financial characteristics 
    AVG(hos_total_revenue)/1000000 as avg_revenue_millions,
    SUM(CASE WHEN sys_highucburden = 1 THEN 1 ELSE 0 END) as high_uncomp_care_systems
  FROM mimi_ws_1.ahrq.compendium_us_health_systems
  GROUP BY health_sys_state
)

SELECT
  health_sys_state,
  num_systems,
  ROUND(avg_physicians, 1) as avg_physicians,
  ROUND(avg_hospitals, 1) as avg_hospitals,
  ROUND(avg_beds, 0) as avg_beds,
  major_teaching_systems,
  systems_with_childrens,
  ROUND(avg_revenue_millions, 1) as avg_revenue_millions,
  high_uncomp_care_systems
FROM system_stats
WHERE health_sys_state IS NOT NULL
ORDER BY num_systems DESC
LIMIT 10;

/*
How it works:
1. Creates a CTE to calculate state-level statistics
2. Aggregates key metrics using COUNT, AVG and SUM
3. Formats and rounds results for readability
4. Shows top 10 states by number of health systems

Assumptions & Limitations:
- Assumes data completeness and accuracy
- Revenue figures may not include all sources
- State-level analysis may mask regional variations
- Limited to systems meeting AHRQ definition criteria

Possible Extensions:
1. Add temporal analysis using mimi_src_file_date
2. Include urban/rural comparisons
3. Analyze insurance/payment model participation
4. Compare system ownership types
5. Map geographic coverage patterns
6. Analyze physician specialty mix
7. Study teaching intensity patterns
8. Examine uncompensated care distribution
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:14:25.526944
    - Additional Notes: Query aggregates healthcare system metrics at state level, focusing on capacity, teaching status, and financial characteristics. Best used for high-level geographic comparisons and resource distribution analysis. Note that smaller states may have limited data points which could affect averages.
    
    */