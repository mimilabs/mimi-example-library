-- os_specialty_concentration.sql
-- Business Purpose: Analyze the concentration of medical specialties across health systems
-- to identify potential gaps in specialty coverage and opportunities for strategic expansion.
-- This analysis helps healthcare executives make informed decisions about:
-- - Service line development
-- - Market expansion opportunities 
-- - Competitive positioning
-- - Resource allocation

WITH specialty_counts AS (
    -- Calculate specialty counts per health system
    SELECT 
        health_sys_id,
        health_sys_name,
        os_specialty,
        COUNT(*) as specialty_sites,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY health_sys_id) as specialty_percentage
    FROM mimi_ws_1.ahrq.compendium_outpatient_linkage
    WHERE health_sys_id IS NOT NULL 
    AND os_specialty IS NOT NULL
    GROUP BY health_sys_id, health_sys_name, os_specialty
),

system_metrics AS (
    -- Get total sites and unique specialties per system
    SELECT 
        health_sys_id,
        COUNT(DISTINCT os_specialty) as unique_specialties,
        COUNT(*) as total_sites
    FROM mimi_ws_1.ahrq.compendium_outpatient_linkage
    WHERE health_sys_id IS NOT NULL
    GROUP BY health_sys_id
)

SELECT 
    sc.health_sys_name,
    sc.os_specialty,
    sc.specialty_sites,
    ROUND(sc.specialty_percentage, 1) as specialty_percentage,
    sm.unique_specialties,
    sm.total_sites,
    CASE 
        WHEN sc.specialty_percentage > 25 THEN 'High Concentration'
        WHEN sc.specialty_percentage > 10 THEN 'Moderate Concentration'
        ELSE 'Low Concentration'
    END as concentration_level
FROM specialty_counts sc
JOIN system_metrics sm ON sc.health_sys_id = sm.health_sys_id
WHERE sc.specialty_percentage >= 5  -- Focus on meaningful concentrations
ORDER BY sc.health_sys_name, sc.specialty_percentage DESC;

-- How it works:
-- 1. First CTE calculates the count and percentage of each specialty within each health system
-- 2. Second CTE computes system-level metrics including total sites and unique specialties
-- 3. Main query joins these together and adds concentration categorization
-- 4. Results are filtered to show only meaningful concentrations (>=5%)

-- Assumptions and Limitations:
-- - Assumes os_specialty field is consistently coded
-- - Does not account for the size/capacity of individual sites
-- - Does not consider geographic distribution within health systems
-- - Limited to health systems with valid health_sys_id

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Include physician count (os_mds) to weight the analysis
-- 3. Compare specialty mix to local market demographics
-- 4. Add year-over-year trend analysis using mimi_src_file_date
-- 5. Include market competition analysis by cbsa_code

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:10:57.009017
    - Additional Notes: Query provides strategic insights into specialty service concentration but may need adjustment of the 5% threshold and concentration level breakpoints (25%/10%) based on specific market conditions and organizational size. Consider healthcare regulations and regional standards when interpreting results.
    
    */