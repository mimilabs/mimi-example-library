/* Buprenorphine Treatment Coverage Gap Analysis by County
   
Business Purpose: 
This query identifies counties with potential treatment coverage gaps by comparing 
total provider capacity to high-need indicators. The analysis helps healthcare 
organizations and policymakers prioritize areas for expanding MAT services.
*/

WITH county_metrics AS (
    SELECT 
        state,
        county,
        -- Calculate proportion of high-capacity providers
        ROUND(number_of_providers_with_275patient_waivers::FLOAT / 
              NULLIF(total_number_of_waivered_providers, 0) * 100, 1) as pct_high_capacity_providers,
        patient_capacity,
        high_need_for_treatment_services,
        lowtono_patient_capacity,
        -- Flag concerning counties
        CASE 
            WHEN high_need_for_treatment_services = TRUE 
            AND lowtono_patient_capacity = TRUE THEN TRUE 
            ELSE FALSE 
        END as critical_gap_area
    FROM mimi_ws_1.hhsoig.buprenorphine_countydata
    WHERE total_number_of_waivered_providers > 0
)

SELECT 
    state,
    -- Aggregate county metrics
    COUNT(DISTINCT county) as total_counties,
    COUNT(DISTINCT CASE WHEN critical_gap_area THEN county END) as counties_with_critical_gaps,
    ROUND(AVG(CASE WHEN critical_gap_area THEN patient_capacity END)) as avg_capacity_in_gap_areas,
    ROUND(AVG(pct_high_capacity_providers), 1) as avg_pct_high_capacity_providers,
    -- Calculate risk score
    ROUND(COUNT(DISTINCT CASE WHEN critical_gap_area THEN county END)::FLOAT / 
          NULLIF(COUNT(DISTINCT county), 0) * 100, 1) as pct_counties_at_risk
FROM county_metrics
GROUP BY state
HAVING COUNT(DISTINCT CASE WHEN critical_gap_area THEN county END) > 0
ORDER BY pct_counties_at_risk DESC;

/* How the Query Works:
1. Creates a CTE to calculate key metrics at the county level
2. Identifies critical gap areas where high need meets low capacity
3. Aggregates results by state to show geographic distribution of coverage gaps
4. Includes percentage calculations to normalize across different state sizes

Assumptions & Limitations:
- Assumes current provider capacity data is accurate and up-to-date
- Does not account for cross-county patient travel patterns
- May underestimate coverage in areas near state borders
- Limited to binary high-need classification

Possible Extensions:
1. Add temporal analysis to track gap changes over time
2. Include demographic factors to assess disparities
3. Calculate distance to nearest high-capacity provider
4. Incorporate actual utilization data from claims
5. Add economic indicators to assess resource allocation needs
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:28:00.354926
    - Additional Notes: Query specifically focuses on identifying states with critical treatment coverage gaps by analyzing the mismatch between provider capacity and high-need areas. The pct_counties_at_risk metric provides a standardized way to compare states regardless of their size or total number of counties. Consider running this analysis quarterly to track improvements in coverage.
    
    */