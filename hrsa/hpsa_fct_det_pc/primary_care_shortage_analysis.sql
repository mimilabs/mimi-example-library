
-- HRSA HPSA Primary Care Shortage Analysis
-- Purpose: Identify and prioritize primary care provider shortage areas for strategic resource allocation

WITH shortage_priority AS (
    -- Rank HPSA areas by critical shortage indicators
    SELECT 
        hpsa_name,
        primary_state_name,
        hpsa_score,
        hpsa_designation_population,
        hpsa_fte AS providers_needed,
        pct_of_population_below_100pct_poverty,
        metropolitan_indicator,
        RANK() OVER (ORDER BY hpsa_score DESC, hpsa_designation_population DESC) AS shortage_priority_rank
    FROM mimi_ws_1.hrsa.hpsa_fct_det_pc
    WHERE 
        hpsa_discipline_class = 'Primary Care'
        AND hpsa_status = 'Designated'
        AND hpsa_score > 15  -- Focus on most critical shortage areas
)

SELECT 
    primary_state_name,
    COUNT(*) AS total_critical_shortage_areas,
    ROUND(AVG(hpsa_score), 2) AS avg_shortage_score,
    ROUND(SUM(hpsa_designation_population), 0) AS total_population_impacted,
    ROUND(SUM(providers_needed), 2) AS total_providers_needed,
    ROUND(AVG(pct_of_population_below_100pct_poverty), 2) AS avg_poverty_percentage
FROM shortage_priority
GROUP BY primary_state_name
ORDER BY total_critical_shortage_areas DESC, avg_shortage_score DESC
LIMIT 25;

-- Query Mechanics:
-- 1. Filters for active, primary care designated shortage areas
-- 2. Ranks areas by HPSA score and population
-- 3. Aggregates state-level shortage metrics
-- 4. Provides comprehensive view of provider shortages

-- Key Assumptions:
-- - Only considers currently designated HPSA areas
-- - Focuses on areas with HPSA score > 15
-- - Aggregates at state level for high-level policy insights

-- Potential Extensions:
-- 1. Add urban/rural breakdown
-- 2. Include longitudinal comparison of shortage trends
-- 3. Integrate with provider training/recruitment program data


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:09:14.182981
    - Additional Notes: This query provides a high-level overview of primary care provider shortages across U.S. states, focusing on areas with critical shortage scores. It may underrepresent nuanced local variations and relies on current HRSA designation data.
    
    */