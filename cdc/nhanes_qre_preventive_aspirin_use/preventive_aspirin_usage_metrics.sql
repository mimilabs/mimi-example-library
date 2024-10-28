/*
Title: Preventive Aspirin Use Analysis - Core Metrics

Business Purpose:
This query analyzes key metrics around preventive aspirin use based on CDC NHANES survey data.
It provides insights into:
- Provider recommendation rates
- Patient adherence to recommendations
- Self-initiated preventive aspirin use
- Overall preventive aspirin usage patterns

These metrics help healthcare organizations understand preventive care patterns
and identify potential gaps in preventive aspirin recommendations and adherence.
*/

WITH aspirin_metrics AS (
    SELECT 
        -- Calculate total respondents
        COUNT(*) as total_respondents,
        
        -- Provider recommendations
        SUM(CASE WHEN rxq510 = 1 THEN 1 ELSE 0 END) as received_recommendation,
        
        -- Following provider advice
        SUM(CASE WHEN rxq515 = 1 THEN 1 ELSE 0 END) as following_recommendation,
        
        -- Self-initiated use
        SUM(CASE WHEN rxq520 = 1 THEN 1 ELSE 0 END) as self_initiated_use,
        
        -- Daily aspirin use (combining provider-recommended and self-initiated)
        SUM(CASE WHEN rxq525g = 1 THEN 1 ELSE 0 END) as daily_users
    FROM mimi_ws_1.cdc.nhanes_qre_preventive_aspirin_use
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.cdc.nhanes_qre_preventive_aspirin_use)
)

SELECT 
    total_respondents,
    received_recommendation,
    ROUND(100.0 * received_recommendation / total_respondents, 1) as pct_received_recommendation,
    following_recommendation,
    ROUND(100.0 * following_recommendation / received_recommendation, 1) as pct_adherence,
    self_initiated_use,
    ROUND(100.0 * self_initiated_use / total_respondents, 1) as pct_self_initiated,
    daily_users,
    ROUND(100.0 * daily_users / total_respondents, 1) as pct_daily_users
FROM aspirin_metrics;

/*
How the Query Works:
1. Uses CTE to calculate core metrics from the raw data
2. Focuses on most recent data using latest mimi_src_file_date
3. Calculates both absolute numbers and percentages
4. Provides comprehensive view of preventive aspirin use patterns

Assumptions and Limitations:
- Assumes latest mimi_src_file_date represents most current survey data
- Does not account for missing or invalid responses
- Does not segment by demographics or other factors
- Focuses on high-level metrics only

Possible Extensions:
1. Add demographic breakdowns (if available through joins)
2. Trend analysis over multiple time periods
3. Detailed analysis of dosage patterns using rxd530
4. Geographic analysis if location data available
5. Cross-tabulation of provider recommendations vs self-initiated use
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:40:00.218889
    - Additional Notes: Query leverages the latest survey data to calculate key metrics around preventive aspirin usage including provider recommendations, patient adherence, and self-initiated use. Note that percentages are calculated based on valid responses only, and the analysis assumes completeness of the latest survey data.
    
    */