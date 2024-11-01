-- Title: NHANES Youth Tobacco Exposure Analysis
-- 
-- Business Purpose:
-- - Identify tobacco exposure patterns among young respondents
-- - Support public health interventions targeting youth tobacco use
-- - Provide metrics for evaluating effectiveness of youth tobacco prevention programs
-- - Generate insights for policy recommendations around youth tobacco access

WITH tobacco_use AS (
    -- First identify any tobacco product usage in past 5 days
    SELECT 
        seqn,
        CASE WHEN smq68_ = 1 THEN 1 ELSE 0 END as any_tobacco_use,
        CASE WHEN smq690a = 1 THEN 1 ELSE 0 END as cigarette_use,
        CASE WHEN smq690h = 1 THEN 1 ELSE 0 END as ecigarette_use,
        smq710 as days_smoked_past5,
        smq720 as cigs_per_day,
        smq849 as days_ecig_past5,
        mimi_src_file_date as survey_date
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_recent_tobacco_use
    WHERE smq68_ IS NOT NULL
),

usage_metrics AS (
    -- Calculate key usage metrics
    SELECT
        survey_date,
        COUNT(DISTINCT seqn) as total_respondents,
        SUM(any_tobacco_use) as total_tobacco_users,
        SUM(cigarette_use) as cigarette_users,
        SUM(ecigarette_use) as ecig_users,
        ROUND(AVG(CASE WHEN cigarette_use = 1 THEN days_smoked_past5 END), 1) as avg_smoking_days,
        ROUND(AVG(CASE WHEN ecigarette_use = 1 THEN days_ecig_past5 END), 1) as avg_ecig_days
    FROM tobacco_use
    GROUP BY survey_date
)

SELECT
    survey_date,
    total_respondents,
    -- Calculate prevalence rates
    ROUND(100.0 * total_tobacco_users / total_respondents, 1) as tobacco_prevalence_pct,
    ROUND(100.0 * cigarette_users / total_respondents, 1) as cigarette_prevalence_pct,
    ROUND(100.0 * ecig_users / total_respondents, 1) as ecig_prevalence_pct,
    -- Usage intensity metrics
    avg_smoking_days,
    avg_ecig_days,
    -- Calculate dual use
    ROUND(100.0 * (cigarette_users + ecig_users - total_tobacco_users) / total_tobacco_users, 1) as dual_use_pct
FROM usage_metrics
ORDER BY survey_date;

/* How this query works:
1. Creates base table of individual tobacco use patterns
2. Aggregates into survey-level metrics
3. Calculates prevalence rates and usage patterns
4. Identifies dual use of traditional and e-cigarettes

Assumptions and Limitations:
- Assumes survey responses are representative of population
- Limited to past 5-day usage window
- Does not account for seasonal variations
- Missing demographic stratification
- Self-reported data may have recall bias

Possible Extensions:
1. Add demographic breakdowns (age groups, gender, etc.)
2. Include trend analysis across multiple survey years
3. Add comparison of weekday vs weekend usage patterns
4. Incorporate analysis of quit attempts and cessation methods
5. Add geographic analysis if location data available
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:54:20.975498
    - Additional Notes: Query focuses on temporal patterns of youth tobacco use, particularly dual use of traditional and electronic cigarettes. Consider adding risk factor analysis or socioeconomic correlations for more comprehensive insights. May need adjustment of date ranges based on available survey periods.
    
    */