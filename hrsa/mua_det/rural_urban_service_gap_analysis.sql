-- Title: MUA/P Geographic Distribution and IMU Score Analysis by Rural Status

-- Business Purpose:
-- This query analyzes the geographic distribution of Medically Underserved Areas/Populations
-- with a focus on rural vs urban disparities and IMU scores. The analysis helps identify
-- areas with the most critical healthcare access needs and supports resource allocation
-- and policy decisions for improving healthcare access in underserved communities.

WITH active_designations AS (
    -- Filter for active MUA/P designations only
    SELECT 
        muap_service_area_name,
        designation_type,
        rural_status_description,
        imu_score,
        state_name,
        hhs_region_name,
        providers_per_1000_population,
        percent_of_population_with_incomes_at_or_below_100_percent_of_the_us_federal_poverty_level
    FROM mimi_ws_1.hrsa.mua_det
    WHERE muap_status_description = 'Designated'
    AND imu_score IS NOT NULL
)

SELECT 
    -- Group designations by rural status and region
    rural_status_description,
    hhs_region_name,
    state_name,
    COUNT(*) as designation_count,
    
    -- Calculate key metrics
    ROUND(AVG(imu_score), 2) as avg_imu_score,
    ROUND(MIN(imu_score), 2) as min_imu_score,
    ROUND(AVG(providers_per_1000_population), 3) as avg_providers_per_1000,
    ROUND(AVG(percent_of_population_with_incomes_at_or_below_100_percent_of_the_us_federal_poverty_level), 2) as avg_poverty_rate
FROM active_designations
GROUP BY 
    rural_status_description,
    hhs_region_name,
    state_name
ORDER BY 
    hhs_region_name,
    state_name,
    avg_imu_score ASC

-- How it works:
-- 1. First CTE filters for active designations and relevant columns
-- 2. Main query aggregates data by rural status and geography
-- 3. Calculates average IMU scores and other key metrics
-- 4. Orders results to highlight areas with greatest need (lowest IMU scores)

-- Assumptions and Limitations:
-- - Only includes active designations
-- - Requires valid IMU scores (null values excluded)
-- - Rural status classification is based on HRSA definitions
-- - Analysis is at state/region level, may mask local variations

-- Possible Extensions:
-- 1. Add trend analysis by comparing designation dates
-- 2. Include population size weights in averages
-- 3. Add statistical significance testing between rural/urban areas
-- 4. Incorporate time-based changes in provider ratios
-- 5. Add geographic clustering analysis of high-need areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:58:03.004342
    - Additional Notes: Query focuses on rural-urban disparities in medical underservice, providing granular analysis by HHS region and state. Key metrics include IMU scores, provider ratios, and poverty rates. Useful for identifying geographic patterns in healthcare access gaps and resource allocation needs. Note that rural status classifications should be validated against current HRSA definitions.
    
    */