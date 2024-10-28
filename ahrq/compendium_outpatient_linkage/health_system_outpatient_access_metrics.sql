
/*******************************************************************************
Title: Health System Outpatient Site Distribution and Access Analysis

Business Purpose:
This query analyzes the distribution and accessibility of outpatient healthcare 
sites across different geographic areas, with a focus on identifying potential
healthcare access disparities. It provides insights into:
- Geographic concentration of outpatient sites by health system
- Sites in medically underserved or shortage areas
- Rural vs urban distribution
- Physician availability

These metrics help healthcare planners and policymakers understand where
additional outpatient facilities may be needed.
*******************************************************************************/

WITH health_sys_metrics AS (
  -- Aggregate metrics by health system
  SELECT 
    health_sys_id,
    health_sys_name,
    COUNT(DISTINCT compendium_os_id) as total_sites,
    SUM(os_mds) as total_physicians,
    COUNT(DISTINCT CASE WHEN mua = 1 THEN compendium_os_id END) as underserved_sites,
    COUNT(DISTINCT CASE WHEN rural_nonmsa = 1 THEN compendium_os_id END) as rural_sites
  FROM mimi_ws_1.ahrq.compendium_outpatient_linkage
  WHERE health_sys_id IS NOT NULL
  GROUP BY 1,2
)

SELECT
  h.health_sys_name,
  h.total_sites,
  h.total_physicians,
  -- Calculate key access metrics
  ROUND(h.underserved_sites * 100.0 / h.total_sites, 1) as pct_underserved,
  ROUND(h.rural_sites * 100.0 / h.total_sites, 1) as pct_rural,
  ROUND(h.total_physicians * 1.0 / h.total_sites, 1) as avg_physicians_per_site
FROM health_sys_metrics h
WHERE h.total_sites >= 5  -- Focus on systems with meaningful presence
ORDER BY h.total_sites DESC
LIMIT 20  -- Show top 20 largest systems by site count

/*******************************************************************************
How the Query Works:
1. First CTE aggregates key metrics by health system
2. Main query calculates derived metrics and filters/formats results
3. Results show largest health systems and their outpatient site characteristics

Assumptions & Limitations:
- Assumes health_sys_id and site IDs are populated correctly
- Limited to systems with 5+ sites to focus on major players
- Does not account for site size/capacity beyond physician count
- Point-in-time snapshot based on latest data load

Possible Extensions:
1. Add geographic analysis by state/region
2. Include trending over time using mimi_src_file_date
3. Add specialty mix analysis using os_specialty
4. Incorporate population density data for access analysis
5. Add detailed HPSA shortage area analysis using pchpsa fields
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:15:22.985348
    - Additional Notes: Query focuses on large health systems (5+ sites) and calculates key access metrics including rural coverage and physician distribution. Results are limited to top 20 systems by site count. Consider adjusting the site threshold (currently 5) based on analysis needs. Medically underserved area (MUA) calculations assume binary flags are correctly populated in source data.
    
    */