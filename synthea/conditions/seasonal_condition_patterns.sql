-- Title: Patient Condition Onset Pattern Analysis by Season and Age Group
-- Business Purpose:
-- - Understand seasonal patterns in condition diagnoses to optimize staffing and resources
-- - Identify age-specific condition trends to support preventive care programs
-- - Enable proactive healthcare planning based on demographic and temporal factors
-- Created: 2024-02-09
-- Author: Healthcare Analytics Team

WITH age_groups AS (
    -- Calculate patient ages and group them
    SELECT 
        patient,
        FLOOR(DATEDIFF('2024-01-01', DATE(SUBSTRING(patient, 1, 10))) / 10) * 10 AS age_group
    FROM mimi_ws_1.synthea.conditions
    GROUP BY patient
),

seasonal_onsets AS (
    -- Analyze condition onsets by season
    SELECT 
        c.description,
        CASE 
            WHEN MONTH(c.start) IN (12,1,2) THEN 'Winter'
            WHEN MONTH(c.start) IN (3,4,5) THEN 'Spring'
            WHEN MONTH(c.start) IN (6,7,8) THEN 'Summer'
            ELSE 'Fall'
        END AS season,
        ag.age_group,
        COUNT(*) as condition_count
    FROM mimi_ws_1.synthea.conditions c
    JOIN age_groups ag ON c.patient = ag.patient
    WHERE c.start >= '2020-01-01' -- Focus on recent data
    GROUP BY c.description, season, ag.age_group
)

SELECT 
    description,
    season,
    age_group,
    condition_count,
    ROUND(100.0 * condition_count / SUM(condition_count) OVER (PARTITION BY description), 2) as season_percentage
FROM seasonal_onsets
WHERE condition_count > 10 -- Filter for statistical significance
ORDER BY description, condition_count DESC;

-- How the Query Works:
-- 1. Creates age groups based on patient identifiers
-- 2. Categorizes conditions by seasons using start dates
-- 3. Combines seasonal and age group information
-- 4. Calculates the distribution of conditions across seasons
-- 5. Filters for statistically significant counts
-- 6. Presents results with percentage distributions

-- Assumptions and Limitations:
-- - Assumes patient IDs contain birth dates in their first 10 characters
-- - Limited to conditions starting from 2020 onwards
-- - Requires minimum condition count of 10 for inclusion
-- - Age groups are calculated as of 2024-01-01
-- - Seasons are defined by standard calendar months

-- Possible Extensions:
-- 1. Add geographic analysis if location data becomes available
-- 2. Include year-over-year trend analysis
-- 3. Incorporate condition severity or risk stratification
-- 4. Add correlation analysis with environmental factors
-- 5. Expand to include cost impact analysis
-- 6. Create forecasting model based on seasonal patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:12:19.942966
    - Additional Notes: The query focuses on analyzing 3-year seasonal patterns since 2020. Consider adjusting the date range (2020-01-01) and minimum condition count (10) based on your specific analysis needs. The age group calculation assumes a specific patient ID format - verify this matches your data structure before running.
    
    */