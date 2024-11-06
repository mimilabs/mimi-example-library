-- physician_density_health_systems.sql
--
-- Business Purpose: Analyze physician staffing patterns across health systems and geographic regions
-- to identify potential workforce optimization opportunities and recruitment needs. This analysis
-- helps healthcare executives make data-driven decisions about physician workforce planning,
-- resource allocation, and market expansion strategies.

WITH physician_metrics AS (
    -- Calculate average physicians per site and total physicians for each health system
    SELECT 
        health_sys_id,
        health_sys_name,
        health_sys_state,
        COUNT(DISTINCT compendium_os_id) as total_sites,
        SUM(os_mds) as total_physicians,
        ROUND(AVG(os_mds), 2) as avg_physicians_per_site,
        ROUND(SUM(os_mds) * 1.0 / COUNT(DISTINCT compendium_os_id), 2) as physician_site_ratio
    FROM mimi_ws_1.ahrq.compendium_outpatient_linkage
    WHERE health_sys_id IS NOT NULL 
    AND os_mds > 0
    GROUP BY health_sys_id, health_sys_name, health_sys_state
)

SELECT 
    pm.*,
    -- Calculate percentile ranks for physician metrics
    ROUND(PERCENT_RANK() OVER (ORDER BY total_physicians), 2) as physician_count_percentile,
    ROUND(PERCENT_RANK() OVER (ORDER BY physician_site_ratio), 2) as physician_ratio_percentile,
    -- Add rankings within state
    RANK() OVER (PARTITION BY health_sys_state ORDER BY total_physicians DESC) as state_rank_by_physicians
FROM physician_metrics pm
WHERE total_sites >= 5  -- Focus on systems with meaningful presence
ORDER BY total_physicians DESC
LIMIT 100;

/* How this query works:
1. Creates a CTE to aggregate physician staffing metrics by health system
2. Calculates key metrics including total physicians, sites, and ratios
3. Adds percentile rankings to contextualize system size and staffing intensity
4. Filters for systems with at least 5 sites to ensure meaningful comparison
5. Orders results by total physician count

Assumptions and limitations:
- Assumes os_mds (physician count) data is accurate and current
- Limited to systems with complete health_sys_id and physician count data
- May not account for part-time physicians or other clinical staff
- State-level rankings may be skewed in states with few health systems

Possible extensions:
1. Add year-over-year comparison to track staffing trends
2. Include additional clinical staff categories beyond physicians
3. Segment analysis by urban/rural designation
4. Add specialty mix analysis to understand physician distribution
5. Compare physician density to local population metrics
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:35:06.682389
    - Additional Notes: Query focuses on health systems with 5+ sites and active physician staffing. Provides both absolute numbers and relative rankings (percentiles) to enable meaningful system-to-system comparisons. Key metrics include physician-to-site ratios and state-level rankings, making it particularly useful for workforce planning and competitive analysis.
    
    */