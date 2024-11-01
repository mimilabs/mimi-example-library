/*
Title: NHANES Coffee/Tea Consumption Impact Analysis

Business Purpose:
This analysis examines patient coffee/tea consumption patterns before lab tests to:
1. Identify potential impacts on morning vs afternoon test scheduling
2. Understand patient compliance challenges with fasting requirements
3. Support lab operations planning based on patient beverage consumption habits

Key stakeholders:
- Lab Operations Managers
- Clinical Research Teams
- Patient Experience Teams
*/

WITH coffee_consumption AS (
    -- Calculate total time since coffee consumption in minutes
    SELECT 
        seqn,
        phdsesn,
        phq020 as had_coffee_or_tea,
        (COALESCE(phacofhr, 0) * 60 + COALESCE(phacofmn, 0)) as mins_since_coffee
    FROM mimi_ws_1.cdc.nhanes_lab_fasting_questionnaire
    WHERE phq020 IS NOT NULL
),

session_metrics AS (
    -- Calculate key metrics by session
    SELECT
        phdsesn as session_time,
        COUNT(*) as total_patients,
        COUNT(CASE WHEN had_coffee_or_tea = 1 THEN 1 END) as patients_with_coffee,
        ROUND(AVG(mins_since_coffee),1) as avg_mins_since_coffee,
        ROUND(STDDEV(mins_since_coffee),1) as stddev_mins_since_coffee
    FROM coffee_consumption
    WHERE phdsesn IN ('Morning', 'Afternoon')
    GROUP BY phdsesn
)

SELECT 
    session_time,
    total_patients,
    patients_with_coffee,
    ROUND(100.0 * patients_with_coffee / total_patients, 1) as pct_with_coffee,
    avg_mins_since_coffee,
    stddev_mins_since_coffee
FROM session_metrics
ORDER BY session_time;

/*
How it works:
1. First CTE identifies coffee/tea consumers and standardizes time measurements
2. Second CTE aggregates metrics by session time
3. Final query calculates percentages and formats output

Assumptions & Limitations:
- Assumes morning/afternoon are only valid session times
- Null handling may affect averages
- Self-reported data may have recall bias
- Does not account for seasonal variations

Possible Extensions:
1. Add trend analysis across multiple years
2. Include demographic breakdowns
3. Correlate with specific lab test results
4. Add analysis of other beverages (alcohol, etc.)
5. Create risk stratification based on consumption patterns
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:39:44.487141
    - Additional Notes: Query provides statistical breakdown of coffee/tea consumption patterns by session time. Key metrics include participation rates and time-since-consumption. Note that statistical calculations exclude null values and rely on self-reported data which may contain reporting bias.
    
    */