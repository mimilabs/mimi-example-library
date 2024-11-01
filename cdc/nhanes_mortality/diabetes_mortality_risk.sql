-- Diabetes Mortality Risk Analysis from NHANES Data
-- Business Purpose: Analyze the relationship between diabetes and mortality outcomes
-- to understand the impact of diabetes on survival and inform population health management strategies.
-- This analysis helps healthcare organizations prioritize diabetes prevention and management programs.

WITH eligible_population AS (
    -- Filter to eligible participants with valid follow-up data
    SELECT *
    FROM mimi_ws_1.cdc.nhanes_mortality
    WHERE eligstat = 1 
    AND permth_int > 0
),

mortality_metrics AS (
    -- Calculate key mortality metrics for diabetic vs non-diabetic populations
    SELECT 
        diabetes,
        COUNT(*) as total_participants,
        SUM(CASE WHEN mortstat = 1 THEN 1 ELSE 0 END) as deaths,
        AVG(permth_int/12.0) as avg_followup_years,
        SUM(CASE WHEN mortstat = 1 THEN 1 ELSE 0 END) * 1000.0 / 
            SUM(permth_int/12.0) as mortality_rate_per_1000_person_years
    FROM eligible_population
    GROUP BY diabetes
)

SELECT
    CASE 
        WHEN diabetes = 1 THEN 'Diabetic'
        WHEN diabetes = 0 THEN 'Non-Diabetic'
    END as population_group,
    total_participants,
    deaths,
    ROUND(avg_followup_years, 1) as avg_followup_years,
    ROUND(mortality_rate_per_1000_person_years, 2) as mortality_rate_per_1000_person_years,
    ROUND(mortality_rate_per_1000_person_years / 
        FIRST_VALUE(mortality_rate_per_1000_person_years) OVER (ORDER BY diabetes), 2) 
        as relative_risk
FROM mortality_metrics
ORDER BY diabetes;

-- How this query works:
-- 1. Filters to eligible participants with valid follow-up data
-- 2. Calculates key mortality metrics for diabetic and non-diabetic groups
-- 3. Computes mortality rates per 1000 person-years and relative risk
-- 4. Presents results in a clear, business-friendly format

-- Assumptions and Limitations:
-- - Assumes diabetes status from death certificate is representative of lifetime status
-- - Does not account for potential confounding factors (age, sex, other conditions)
-- - Limited to participants with complete follow-up data
-- - Does not capture diabetes severity or duration

-- Possible Extensions:
-- 1. Add stratification by age groups or gender
-- 2. Include analysis of specific causes of death in diabetic population
-- 3. Compare outcomes with hypertension co-morbidity
-- 4. Add time-based trends analysis
-- 5. Calculate adjusted mortality rates standardized to population demographics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:28:32.806401
    - Additional Notes: Query calculates mortality rates and relative risk ratios for diabetic vs non-diabetic populations using person-years methodology. Results are presented as rates per 1000 person-years of follow-up, making it suitable for epidemiological analysis and healthcare planning. Note that the relative risk calculation uses non-diabetic population as the reference group.
    
    */