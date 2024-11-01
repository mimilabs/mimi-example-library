-- Title: Rural vs Urban Dental HPSA Access Gap Analysis
-- 
-- Business Purpose: 
-- Analyzes disparities in dental care access between rural and urban areas by comparing
-- key shortage metrics. This helps identify where resource allocation and policy
-- interventions may be needed most to address dental care inequities.
--
-- The analysis supports:
-- - Rural healthcare planning initiatives
-- - Resource allocation decisions
-- - Policy development for addressing dental care disparities
-- - Grant funding prioritization

WITH CurrentHPSAs AS (
    -- Filter to currently designated HPSAs only
    SELECT 
        metropolitan_indicator,
        hpsa_designation_population,
        hpsa_formal_ratio,
        hpsa_score,
        hpsa_fte,
        pct_of_population_below_100pct_poverty
    FROM mimi_ws_1.hrsa.hpsa_fct_det_dh
    WHERE hpsa_status = 'Designated'
    AND hpsa_designation_population > 0
)

SELECT
    -- Group by urban/rural classification
    metropolitan_indicator AS location_type,
    
    -- Population statistics
    COUNT(*) AS num_hpsas,
    SUM(hpsa_designation_population) AS total_population,
    
    -- Access metrics
    ROUND(AVG(hpsa_formal_ratio), 0) AS avg_population_per_provider,
    ROUND(AVG(hpsa_score), 1) AS avg_shortage_severity,
    ROUND(SUM(hpsa_fte), 1) AS total_providers_needed,
    
    -- Poverty context
    ROUND(AVG(pct_of_population_below_100pct_poverty), 1) AS avg_poverty_rate

FROM CurrentHPSAs
GROUP BY metropolitan_indicator
ORDER BY metropolitan_indicator DESC;

-- Query Operation:
-- 1. Filters to active HPSA designations with valid population counts
-- 2. Groups data by metropolitan/rural status
-- 3. Calculates key metrics around population served, provider needs, and poverty
-- 4. Orders results to show urban areas first
--
-- Assumptions & Limitations:
-- - Assumes current designation status is accurate and up-to-date
-- - Limited to areas with reported population counts
-- - Metropolitan indicator is properly maintained
-- - Poverty data may have some gaps
--
-- Possible Extensions:
-- - Add year-over-year trend analysis
-- - Break out by state/region for geographic patterns
-- - Include additional demographic factors
-- - Add statistical significance testing between groups
-- - Calculate confidence intervals for key metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:35:11.977151
    - Additional Notes: Query compares dental care access metrics between rural and urban areas, focusing on population coverage, provider shortages, and poverty rates. Results exclude HPSAs with zero population or non-designated status. Metropolitan indicator classifications should be verified before using for critical decisions.
    
    */