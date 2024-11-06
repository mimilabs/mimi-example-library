-- NHANES Dietary Supplement Analysis
-- Business Purpose: Analyze patterns of dietary supplement consumption before lab tests to:
-- 1. Assess potential impact on lab test validity and interpretation
-- 2. Identify opportunities for improved patient education about supplement usage
-- 3. Support development of lab testing protocols around supplement intake

WITH supplement_timing AS (
    -- Calculate total minutes since last supplement intake
    SELECT 
        seqn,
        phq060 as took_supplements,
        (COALESCE(phasuphr, 0) * 60 + COALESCE(phasupmn, 0)) as minutes_since_supplements,
        phdsesn as session_time,
        mimi_src_file_date
    FROM mimi_ws_1.cdc.nhanes_lab_fasting_questionnaire
    WHERE phq060 IS NOT NULL
),

supplement_metrics AS (
    -- Generate key metrics around supplement consumption
    SELECT 
        mimi_src_file_date,
        COUNT(*) as total_patients,
        SUM(CASE WHEN took_supplements = 1 THEN 1 ELSE 0 END) as supplement_users,
        AVG(CASE WHEN took_supplements = 1 THEN minutes_since_supplements END) as avg_minutes_since_intake,
        ROUND(SUM(CASE WHEN took_supplements = 1 AND minutes_since_supplements < 480 THEN 1 ELSE 0 END) * 100.0 / 
            NULLIF(SUM(CASE WHEN took_supplements = 1 THEN 1 ELSE 0 END), 0), 2) as pct_within_8hrs
    FROM supplement_timing
    GROUP BY mimi_src_file_date
)

SELECT
    mimi_src_file_date as survey_date,
    total_patients,
    supplement_users,
    ROUND(supplement_users * 100.0 / NULLIF(total_patients, 0), 2) as supplement_usage_rate,
    ROUND(avg_minutes_since_intake / 60, 1) as avg_hours_since_intake,
    pct_within_8hrs as pct_taken_within_8hrs
FROM supplement_metrics
ORDER BY mimi_src_file_date;

-- How this query works:
-- 1. Creates a CTE to normalize supplement timing data and handle NULL values
-- 2. Aggregates key metrics around supplement usage patterns
-- 3. Produces final summary showing trends over time in supplement consumption

-- Assumptions and limitations:
-- 1. Assumes supplement intake reporting is accurate
-- 2. Does not distinguish between different types of supplements
-- 3. Missing data is excluded from percentage calculations
-- 4. 8-hour threshold is arbitrary and may need adjustment based on specific lab test requirements

-- Possible extensions:
-- 1. Add analysis by session time to identify morning vs afternoon patterns
-- 2. Cross-reference with specific lab test results
-- 3. Add demographic breakdowns of supplement usage
-- 4. Compare supplement usage with other pre-lab behaviors (coffee, food intake)
-- 5. Create time-based cohorts to analyze seasonal patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:31:32.006987
    - Additional Notes: Query focuses on dietary supplement consumption patterns and compliance timing, providing a longitudinal view of supplement usage before lab tests. Note that the 8-hour threshold used in the analysis is configurable and should be validated against specific lab test requirements.
    
    */