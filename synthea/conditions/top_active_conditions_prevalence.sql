
/* 
Title: Top 10 Most Prevalent Active Medical Conditions Analysis

Business Purpose:
- Identify the most common active medical conditions in the patient population
- Understand the current disease burden to inform healthcare resource allocation
- Support population health management and preventive care initiatives

Author: AI Assistant
Created: 2024
*/

-- Main Query
WITH active_conditions AS (
    -- Filter for currently active conditions (no stop date or stop date is in future)
    SELECT 
        description,
        code,
        COUNT(DISTINCT patient) as patient_count,
        COUNT(*) as total_occurrences,
        ROUND(COUNT(DISTINCT patient) * 100.0 / 
            (SELECT COUNT(DISTINCT patient) FROM mimi_ws_1.synthea.conditions), 2) as prevalence_pct
    FROM mimi_ws_1.synthea.conditions
    WHERE stop IS NULL 
        OR stop >= CURRENT_DATE()
    GROUP BY description, code
)

SELECT 
    description as condition_name,
    code as condition_code,
    patient_count,
    total_occurrences,
    prevalence_pct as population_prevalence_percentage
FROM active_conditions
ORDER BY patient_count DESC
LIMIT 10;

/*
How This Query Works:
1. Creates a CTE for active conditions by filtering out resolved conditions
2. Calculates key metrics including unique patients and prevalence
3. Returns top 10 conditions ordered by number of affected patients

Assumptions & Limitations:
- Assumes NULL stop dates indicate ongoing conditions
- Only considers currently active conditions
- Prevalence is calculated against total patient population
- Synthetic data may not perfectly match real-world disease distributions

Possible Extensions:
1. Add demographic breakdowns (age groups, gender)
2. Include trend analysis by comparing prevalence over time periods
3. Add condition duration analysis for resolved conditions
4. Analyze co-occurring conditions
5. Include severity indicators if available
6. Compare prevalence across different healthcare facilities/regions
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:17:47.775254
    - Additional Notes: The query focuses on active conditions only and calculates prevalence as a percentage of total patient population. Results are synthetic and should be validated against real-world epidemiological data before making clinical or operational decisions. Query performance may be impacted with very large patient populations due to the subquery used in prevalence calculation.
    
    */