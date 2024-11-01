-- NADAC Pharmacy Survey Participation and Coverage Analysis
--
-- Business Purpose:
-- This query analyzes pharmacy participation patterns in NADAC reporting to:
-- 1. Track survey response rates and coverage trends
-- 2. Understand data reliability and comprehensiveness
-- 3. Identify potential gaps in drug pricing data
-- 4. Support policy discussions around NADAC data collection methods

WITH latest_survey AS (
    -- Get the most recent survey period
    SELECT MAX(effective_date) as latest_date
    FROM mimi_ws_1.datamedicaidgov.nadac
),

survey_metrics AS (
    -- Calculate key survey metrics by month
    SELECT 
        DATE_TRUNC('month', effective_date) as survey_month,
        COUNT(DISTINCT ndc) as total_drugs_reported,
        COUNT(DISTINCT CASE WHEN explanation_code = '1' THEN ndc END) as new_survey_drugs,
        COUNT(DISTINCT CASE WHEN explanation_code = '2' THEN ndc END) as carried_forward_within_2pct,
        COUNT(DISTINCT CASE WHEN explanation_code = '4' THEN ndc END) as carried_forward_other
    FROM mimi_ws_1.datamedicaidgov.nadac
    WHERE effective_date >= ADD_MONTHS((SELECT latest_date FROM latest_survey), -12)
    GROUP BY DATE_TRUNC('month', effective_date)
)

SELECT 
    survey_month,
    total_drugs_reported,
    new_survey_drugs,
    carried_forward_within_2pct,
    carried_forward_other,
    ROUND(100.0 * new_survey_drugs / total_drugs_reported, 1) as pct_new_survey,
    ROUND(100.0 * carried_forward_within_2pct / total_drugs_reported, 1) as pct_carried_2pct,
    ROUND(100.0 * carried_forward_other / total_drugs_reported, 1) as pct_carried_other
FROM survey_metrics
ORDER BY survey_month DESC;

-- How this query works:
-- 1. Identifies the most recent survey date in the dataset
-- 2. Analyzes the last 12 months of survey data
-- 3. Calculates monthly metrics on survey participation and data freshness
-- 4. Breaks down drugs by how their prices were determined (new survey vs carried forward)
-- 5. Provides percentage breakdowns to assess data quality

-- Assumptions and Limitations:
-- - Assumes explanation codes accurately reflect survey participation
-- - Limited to last 12 months of data for trending analysis
-- - Does not account for seasonal variations in survey participation
-- - Cannot identify individual pharmacy participation rates

-- Possible Extensions:
-- 1. Add drug classification analysis to see survey coverage by therapeutic class
-- 2. Include pharmacy type indicator analysis for chain vs independent participation
-- 3. Compare survey participation rates across different states or regions
-- 4. Analyze correlation between survey participation and price volatility
-- 5. Track long-term trends in survey participation over multiple years

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:07:54.620755
    - Additional Notes: Query focuses on monitoring data quality and survey participation patterns in NADAC reporting. Results show both absolute numbers and percentages of drugs with new survey data versus carried-forward prices, which helps assess the freshness and reliability of NADAC pricing data. Monthly aggregation allows for identification of trends in survey response rates.
    
    */