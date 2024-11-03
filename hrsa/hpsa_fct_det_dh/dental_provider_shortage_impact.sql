-- Title: Dental HPSA Supply-Demand Mismatch Analysis

-- Business Purpose:
-- Identifies areas where the gap between dental provider supply and population needs
-- is most severe by analyzing provider FTE shortages and formal ratios. This helps
-- healthcare organizations and policymakers prioritize resource allocation and
-- investment decisions for expanding dental care access.

-- Main Query
WITH active_hpsas AS (
    -- Filter to currently designated HPSAs
    SELECT 
        hpsa_name,
        common_state_name,
        designation_type,
        hpsa_fte,
        hpsa_formal_ratio,
        hpsa_designation_population,
        hpsa_estimated_underserved_population
    FROM mimi_ws_1.hrsa.hpsa_fct_det_dh
    WHERE hpsa_status = 'Designated'
        AND hpsa_discipline_class = 'Dental Health'
)

SELECT 
    common_state_name as state,
    designation_type,
    -- Calculate key supply-demand metrics
    COUNT(*) as hpsa_count,
    ROUND(SUM(hpsa_fte), 1) as total_provider_fte_needed,
    ROUND(AVG(hpsa_formal_ratio), 0) as avg_population_per_provider,
    ROUND(SUM(hpsa_designation_population)/1000000, 2) as total_hpsa_population_millions,
    ROUND(SUM(hpsa_estimated_underserved_population)/1000000, 2) as total_underserved_millions
FROM active_hpsas
GROUP BY 1, 2
HAVING total_provider_fte_needed >= 5
ORDER BY total_provider_fte_needed DESC
LIMIT 20;

-- How it works:
-- 1. Filters to active dental HPSAs using CTE
-- 2. Aggregates by state and designation type
-- 3. Calculates key metrics around provider needs and population impact
-- 4. Filters to areas with significant provider shortages
-- 5. Orders by total provider FTEs needed

-- Assumptions & Limitations:
-- - Assumes current HPSA designations are up-to-date
-- - FTE calculations may not account for part-time providers
-- - Population estimates may have some overlap between geographic and population-based designations
-- - Limited to analyzing direct provider shortages, not broader access barriers

-- Possible Extensions:
-- 1. Add trending over time using designation dates
-- 2. Include provider ratio goals and shortage calculations
-- 3. Incorporate geographic coordinates for mapping
-- 4. Add drill-down capability to county/facility level
-- 5. Compare shortages against state dental school graduate rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:25:47.284629
    - Additional Notes: Query focuses on quantifying workforce gaps through FTE needs and population impact. Results are filtered to show only significant shortages (5+ FTEs needed) which may exclude some smaller but still important shortage areas. Population metrics are converted to millions for readability but can be adjusted if more precise figures are needed.
    
    */