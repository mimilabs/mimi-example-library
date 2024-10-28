-- Title: Household Smoking Patterns Analysis from NHANES Survey
/*
Business Purpose:
This query analyzes household smoking patterns using NHANES survey data to understand:
1. The distribution of households with smokers
2. The frequency of indoor smoking
3. The intensity of smoking inside homes (cigarettes per day)
This information is valuable for public health initiatives and understanding secondhand smoke exposure risks.

Created: 2024
*/

WITH smoking_stats AS (
    SELECT 
        -- Count total responses
        COUNT(*) as total_households,
        
        -- Analyze households with smokers
        AVG(CASE WHEN smd460 > 0 THEN 1 ELSE 0 END) * 100 as pct_homes_with_smokers,
        
        -- Analyze indoor smoking patterns
        AVG(CASE WHEN smd470 > 0 THEN 1 ELSE 0 END) * 100 as pct_homes_with_indoor_smokers,
        
        -- Calculate average cigarettes smoked indoors
        AVG(COALESCE(smd430, 0)) as avg_cigarettes_per_day_indoor,
        
        -- Analyze frequency of indoor smoking in past week
        AVG(CASE WHEN smd480 > 0 THEN smd480 ELSE 0 END) as avg_days_smoked_last_week
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers
    WHERE mimi_src_file_date = (
        SELECT MAX(mimi_src_file_date) 
        FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers
    )
)
SELECT 
    total_households,
    ROUND(pct_homes_with_smokers, 1) as pct_homes_with_smokers,
    ROUND(pct_homes_with_indoor_smokers, 1) as pct_homes_with_indoor_smokers,
    ROUND(avg_cigarettes_per_day_indoor, 1) as avg_cigarettes_per_day_indoor,
    ROUND(avg_days_smoked_last_week, 1) as avg_days_smoked_last_week
FROM smoking_stats;

/*
How the Query Works:
1. Uses a CTE to calculate key smoking statistics
2. Focuses on the most recent survey data using the latest mimi_src_file_date
3. Calculates percentages and averages for key smoking metrics
4. Rounds results for better readability

Assumptions and Limitations:
- Assumes non-null values are valid responses
- Does not account for potential survey sampling weights
- Based on self-reported data which may have reporting bias
- Only analyzes the most recent survey period

Possible Extensions:
1. Add trend analysis by comparing multiple survey periods:
   - Add GROUP BY mimi_src_file_date to track changes over time

2. Include demographic analysis:
   - Join with demographic tables to analyze patterns by age, income, or region

3. Add detailed smoking type analysis:
   - Include separate statistics for cigarettes, cigars, and pipes
   - Analyze correlation between number of smokers and indoor smoking rules

4. Create risk categories:
   - Classify households into risk levels based on smoking frequency and intensity
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:06:13.710589
    - Additional Notes: Query uses the most recent survey data only. Consider adding survey weights (if available) for more accurate population-level estimates. Indoor smoking metrics may be underreported due to self-reporting bias.
    
    */