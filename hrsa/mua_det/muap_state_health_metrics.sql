
/*******************************************************************************
Title: Core MUA/P Health Services Analysis

Business Purpose:
This query analyzes the distribution and severity of Medically Underserved Areas/
Populations (MUA/P) across states, providing key metrics about healthcare access
challenges. This information helps healthcare planners and policymakers identify
areas with the greatest need for medical resources and interventions.

Created: 2024-02-14
*******************************************************************************/

-- Main query analyzing MUA/P designations by state with key health metrics
SELECT 
    -- Geographic identifiers
    state_name,
    
    -- Count active designations
    COUNT(*) as total_designations,
    
    -- Calculate average IMU score (lower = greater need)
    ROUND(AVG(imu_score), 1) as avg_imu_score,
    
    -- Key healthcare access metrics
    ROUND(AVG(providers_per_1000_population), 2) as avg_providers_per_1000,
    ROUND(AVG(percent_of_population_with_incomes_at_or_below_100_percent_of_the_us_federal_poverty_level), 1) as avg_poverty_rate,
    ROUND(AVG(infant_mortality_rate), 1) as avg_infant_mortality_rate,
    
    -- Population statistics
    SUM(designation_population_in_a_medically_underserved_area_population_muap) as total_affected_population

FROM mimi_ws_1.hrsa.mua_det

-- Focus on active designations
WHERE muap_status_description = 'Designated'
  AND state_name IS NOT NULL

-- Group results by state
GROUP BY state_name

-- Order by IMU score to highlight areas of greatest need
ORDER BY avg_imu_score;

/*******************************************************************************
How This Query Works:
- Filters for active MUA/P designations only
- Aggregates key healthcare access metrics by state
- Calculates averages for IMU scores and other health indicators
- Shows total affected population per state
- Orders results to highlight states with greatest medical underservice (lowest IMU)

Assumptions and Limitations:
- Assumes current designations are most relevant (filters out historical/withdrawn)
- Does not distinguish between MUA vs MUP designations
- Averages may mask significant variations within states
- Population counts may have some overlap in areas with multiple designations

Possible Extensions:
1. Add time-based analysis to show trends in designations
2. Break down by rural vs urban areas
3. Compare MUA vs MUP characteristics
4. Add geographic analysis using border area indicators
5. Include demographic breakdowns of affected populations
6. Analyze relationship between poverty rates and IMU scores
7. Compare state metrics to national averages
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:12:50.177665
    - Additional Notes: Query focuses on active designations only and provides state-level aggregations. IMU scores are inversely proportional to need (lower scores indicate greater medical underservice). Population counts may include overlaps in areas with multiple designations, so totals should be treated as approximate.
    
    */