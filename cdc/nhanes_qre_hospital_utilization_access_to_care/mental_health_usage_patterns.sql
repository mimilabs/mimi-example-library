-- mental_health_access_analysis.sql

/*
Business Purpose:
This query analyzes patterns in mental health care access and utilization, comparing it with overall healthcare usage.
Key insights:
- Mental health professional consultation rates
- Relationship between general health status and mental health visits
- Access patterns for mental health vs. regular healthcare
- Flags potential gaps in mental health care access

Target audience: Healthcare policy makers, mental health program directors, population health managers
*/

WITH health_status_base AS (
    -- Create base population with general health status
    SELECT 
        huq010 as general_health_status,
        huq030 as has_usual_care_place,
        huq090 as saw_mental_health_prof,
        huq05_ as num_doctor_visits,
        COUNT(*) as patient_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as pct_of_total
    FROM mimi_ws_1.cdc.nhanes_qre_hospital_utilization_access_to_care
    WHERE huq010 IS NOT NULL 
    GROUP BY 1,2,3,4
),

mental_health_summary AS (
    -- Summarize mental health utilization patterns
    SELECT
        CASE huq010 
            WHEN 1 THEN 'Excellent'
            WHEN 2 THEN 'Very Good'
            WHEN 3 THEN 'Good'
            WHEN 4 THEN 'Fair'
            WHEN 5 THEN 'Poor'
        END as health_status,
        CASE huq090
            WHEN 1 THEN 'Yes'
            WHEN 2 THEN 'No'
        END as mental_health_visit,
        COUNT(*) as count,
        AVG(CASE WHEN huq05_ > 0 THEN huq05_ END) as avg_doctor_visits
    FROM mimi_ws_1.cdc.nhanes_qre_hospital_utilization_access_to_care
    WHERE huq010 BETWEEN 1 AND 5
    AND huq090 IN (1,2)
    GROUP BY 1,2
)

SELECT 
    health_status,
    mental_health_visit,
    count,
    ROUND(count * 100.0 / SUM(count) OVER (PARTITION BY health_status), 1) as pct_within_health_status,
    ROUND(avg_doctor_visits, 1) as avg_annual_doctor_visits,
    ROUND(count * 100.0 / SUM(count) OVER (), 1) as pct_of_total_population
FROM mental_health_summary
ORDER BY 
    CASE health_status 
        WHEN 'Excellent' THEN 1
        WHEN 'Very Good' THEN 2
        WHEN 'Good' THEN 3
        WHEN 'Fair' THEN 4
        WHEN 'Poor' THEN 5
    END,
    mental_health_visit;

/*
How it works:
1. First CTE establishes baseline population health metrics
2. Second CTE focuses specifically on mental health utilization
3. Final query combines and presents results with relevant percentages

Assumptions & Limitations:
- Relies on self-reported health status
- Mental health visits are binary (yes/no) without frequency detail
- Does not account for accessibility barriers
- Missing values are excluded from analysis

Possible Extensions:
1. Add demographic breakdowns (would need to join with demographics table)
2. Include temporal trends if multiple years available
3. Incorporate geographic analysis for regional patterns
4. Add insurance status correlation analysis
5. Compare with hospital utilization patterns
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:41:47.168630
    - Additional Notes: Query provides good insights into mental health service utilization but requires the huq090 (mental health visits) field to be populated. Consider adding error handling for NULL values in critical fields and validation for visit counts (huq05_) that may contain outliers or invalid entries.
    
    */