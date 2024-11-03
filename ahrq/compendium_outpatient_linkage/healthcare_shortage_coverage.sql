-- healthcare_shortage_region_coverage.sql

-- Business Purpose: Identify healthcare system coverage in medically underserved areas
-- and primary care shortage regions. This analysis helps healthcare executives and
-- policymakers understand where health systems are addressing (or not addressing) 
-- critical healthcare access needs, informing strategic expansion and resource allocation.

WITH shortage_metrics AS (
    -- Aggregate sites by health system and shortage designation
    SELECT 
        health_sys_id,
        health_sys_name,
        health_sys_state,
        COUNT(*) as total_sites,
        SUM(CASE WHEN mua = 1 THEN 1 ELSE 0 END) as sites_in_underserved_areas,
        SUM(CASE WHEN pchpsa = 1 THEN 1 ELSE 0 END) as sites_in_shortage_areas,
        SUM(os_mds) as total_physicians
    FROM mimi_ws_1.ahrq.compendium_outpatient_linkage
    WHERE health_sys_id IS NOT NULL
    GROUP BY health_sys_id, health_sys_name, health_sys_state
)

SELECT 
    health_sys_name,
    health_sys_state,
    total_sites,
    total_physicians,
    sites_in_underserved_areas,
    sites_in_shortage_areas,
    ROUND(100.0 * sites_in_underserved_areas / total_sites, 1) as pct_in_underserved_areas,
    ROUND(100.0 * sites_in_shortage_areas / total_sites, 1) as pct_in_shortage_areas,
    ROUND(1.0 * total_physicians / total_sites, 1) as avg_physicians_per_site
FROM shortage_metrics
WHERE total_sites >= 5  -- Focus on systems with meaningful presence
ORDER BY total_sites DESC, health_sys_state;

-- How it works:
-- 1. Creates a CTE to aggregate key shortage metrics by health system
-- 2. Calculates percentages of sites in underserved/shortage areas
-- 3. Includes physician density metrics
-- 4. Filters for systems with at least 5 sites for meaningful analysis
-- 5. Orders results by system size and state for easy comparison

-- Assumptions and Limitations:
-- - Assumes MUA and PCHPSA indicators are up to date and accurate
-- - Limited to health systems with known health_sys_id
-- - Does not account for site size/capacity beyond physician count
-- - May not reflect recent changes in health system ownership

-- Possible Extensions:
-- 1. Add trending analysis by comparing against historical data
-- 2. Include geographic clustering analysis of shortage areas
-- 3. Add comparison of rural vs urban shortage coverage
-- 4. Incorporate population health metrics for context
-- 5. Add financial metrics to assess investment needs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:35:11.914925
    - Additional Notes: Query focuses on health systems with 5+ sites for statistical significance. Results may be skewed for systems operating near state borders since analysis is state-based. Physician counts should be validated as some systems may have incomplete data.
    
    */