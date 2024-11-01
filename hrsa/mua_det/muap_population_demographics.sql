-- muap_population_trends.sql
-- Title: Analysis of Population Characteristics and Service Delivery in Medically Underserved Areas

-- Business Purpose:
-- This query examines demographic patterns and service delivery metrics across active MUA/P designations
-- to identify areas with critical healthcare access needs and significant population vulnerabilities.
-- The insights help healthcare organizations and policymakers prioritize resource allocation and
-- understand where targeted interventions may be most impactful.

SELECT 
    state_name,
    COUNT(muap_id) as total_designations,
    
    -- Population metrics
    ROUND(AVG(designation_population_in_a_medically_underserved_area_population_muap), 0) as avg_muap_population,
    ROUND(AVG(percentage_of_population_age_65_and_over), 1) as avg_elderly_pct,
    ROUND(AVG(percent_of_population_with_incomes_at_or_below_100_percent_of_the_us_federal_poverty_level), 1) as avg_poverty_pct,
    
    -- Service delivery metrics
    ROUND(AVG(providers_per_1000_population), 2) as avg_provider_ratio,
    ROUND(AVG(imu_score), 1) as avg_imu_score,
    
    -- Rural characteristics
    SUM(CASE WHEN rural_status_description = 'Rural' THEN 1 ELSE 0 END) as rural_designations,
    ROUND(100.0 * SUM(CASE WHEN rural_status_description = 'Rural' THEN 1 ELSE 0 END) / COUNT(*), 1) as rural_pct

FROM mimi_ws_1.hrsa.mua_det

-- Focus on active designations
WHERE muap_status_description = 'Designated'
  AND designation_population_in_a_medically_underserved_area_population_muap > 0

GROUP BY state_name
HAVING COUNT(muap_id) >= 5  -- Focus on states with meaningful sample sizes

ORDER BY avg_imu_score ASC  -- Prioritize states with greatest need (lower scores)
LIMIT 25;

-- How this works:
-- 1. Filters for active MUA/P designations with non-zero populations
-- 2. Calculates key population and service metrics by state
-- 3. Includes rural designation counts and percentages
-- 4. Orders results by IMU score to highlight areas of greatest need
-- 5. Limits to top 25 states for focused analysis

-- Assumptions and Limitations:
-- - Assumes current designations are up-to-date and accurate
-- - Limited to states with at least 5 designations for statistical relevance
-- - Does not account for population overlap between nearby designations
-- - Rural/urban classification may not capture suburban or mixed areas

-- Possible Extensions:
-- 1. Add time-based trends using designation_date
-- 2. Include geographic clustering analysis
-- 3. Break down by designation_type (MUA vs MUP)
-- 4. Add correlation analysis between metrics
-- 5. Include border region analysis using border indicators
-- 6. Compare metropolitan vs non-metropolitan areas
-- 7. Add population-weighted averages for more accurate state-level metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:41:28.795075
    - Additional Notes: This query provides comprehensive demographic and service delivery insights at the state level, focusing on active MUA/P designations. Consider adjusting the HAVING COUNT threshold based on specific analysis needs, and note that averages are not population-weighted which may impact interpretation for states with varying designation sizes.
    
    */