
/*******************************************************************************
Title: Dental Health Professional Shortage Areas (HPSA) Analysis - Core Metrics

Business Purpose:
This query analyzes the severity and distribution of dental health professional 
shortages across the United States, focusing on key metrics that inform 
healthcare policy and resource allocation decisions. It identifies areas with 
the most critical needs based on HPSA scores, population impact, and provider 
shortages.

Created: 2024
*******************************************************************************/

-- Main analysis of active dental HPSAs by state with critical metrics
SELECT 
    common_state_name as state,
    COUNT(*) as total_hpsas,
    
    -- Calculate average HPSA score to gauge overall severity
    ROUND(AVG(hpsa_score), 1) as avg_hpsa_score,
    
    -- Sum total population affected
    SUM(hpsa_designation_population) as total_affected_population,
    
    -- Sum additional dentists needed
    ROUND(SUM(hpsa_fte), 1) as total_providers_needed,
    
    -- Calculate percentage of rural designations
    ROUND(100.0 * COUNT(CASE WHEN metropolitan_indicator = 'Rural' THEN 1 END) 
          / COUNT(*), 1) as pct_rural_areas,
    
    -- Average poverty rate in HPSAs
    ROUND(AVG(pct_of_population_below_100pct_poverty), 1) as avg_poverty_rate

FROM mimi_ws_1.hrsa.hpsa_fct_det_dh

-- Focus on currently active designations
WHERE hpsa_status = 'Designated'
  AND hpsa_discipline_class = 'Dental Health'

GROUP BY common_state_name
ORDER BY avg_hpsa_score DESC;

/*******************************************************************************
How This Query Works:
- Filters for active dental health HPSA designations only
- Aggregates key metrics by state to show geographic distribution of need
- Calculates both absolute measures (population, providers needed) and 
  relative measures (scores, percentages)

Assumptions & Limitations:
- Assumes current 'Designated' status represents active shortages
- Does not account for partial year designations
- Population counts may include some overlap in geographic areas
- Provider needs (FTE) are estimates based on HRSA methodology

Possible Extensions:
1. Add trend analysis by comparing against historical designations
2. Break down by urban/rural status or specific population groups
3. Include geographic visualization using latitude/longitude
4. Add county-level analysis for more granular insights
5. Compare provider shortages against state demographic data
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:03:41.900677
    - Additional Notes: Query returns active dental shortage areas aggregated by state, with key metrics including HPSA scores, affected population, and provider needs. Results are ordered by severity (HPSA score) to highlight states with most critical shortages. Performance may be impacted when processing states with large numbers of HPSA designations.
    
    */