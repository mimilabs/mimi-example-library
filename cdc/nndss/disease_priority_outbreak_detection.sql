-- CDC NNDSS: National Priority Disease Alert System

/*
Business Purpose:
Create an early warning system for high-risk disease conditions by identifying
emerging disease threats that exceed historical maximum thresholds. This query
helps public health officials and policymakers quickly recognize potential
outbreak scenarios requiring immediate intervention.

Key Business Value:
- Rapid identification of disease conditions exceeding typical reporting levels
- Prioritization of public health resources and emergency response planning
- Comparative analysis of current disease activity against historical patterns
*/

WITH disease_priority_assessment AS (
    SELECT 
        label AS disease_name,
        reporting_area,
        current_mmwr_year,
        mmwr_week,
        current_week AS current_cases,
        previous_52_week_max AS historical_max_cases,
        
        -- Calculate percentage over historical maximum
        CASE 
            WHEN previous_52_week_max > 0 
            THEN ROUND(100.0 * current_week / previous_52_week_max, 2)
            ELSE 0 
        END AS percent_over_historical_max,
        
        -- Priority score based on case volume and historical excess
        CASE 
            WHEN current_week > 1.5 * previous_52_week_max THEN 'High Priority'
            WHEN current_week > previous_52_week_max THEN 'Moderate Priority'
            ELSE 'Standard Monitoring'
        END AS disease_priority_level

    FROM mimi_ws_1.cdc.nndss
    WHERE current_week > 0  -- Exclude zero-case entries
)

SELECT 
    disease_name,
    disease_priority_level,
    reporting_area,
    current_mmwr_year,
    mmwr_week,
    current_cases,
    historical_max_cases,
    percent_over_historical_max
FROM disease_priority_assessment
WHERE disease_priority_level != 'Standard Monitoring'
ORDER BY percent_over_historical_max DESC
LIMIT 25;

/*
Query Mechanics:
1. Calculates current cases against historical maximum
2. Generates a priority classification for disease conditions
3. Filters and ranks diseases exceeding typical reporting thresholds

Assumptions:
- Data represents complete and accurate weekly reporting
- Previous 52-week maximum serves as a reasonable baseline
- Priority levels are dynamically calculated

Potential Extensions:
- Include geographical clustering analysis
- Add demographic segmentation
- Integrate with real-time alerting systems
- Develop predictive models for disease progression

Recommended Next Steps:
- Validate results with epidemiological experts
- Cross-reference with additional data sources
- Develop interactive dashboard for real-time monitoring
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:01:14.143902
    - Additional Notes: Identifies potential disease outbreaks by comparing current case counts to historical maximums. Provides an early warning system for public health officials by highlighting diseases with unusual reporting levels.
    
    */