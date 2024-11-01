-- Title: Aspirin Usage Pattern Analysis by Time and Provider Guidance
-- Business Purpose: Analyze how aspirin usage patterns differ between provider-guided 
-- and self-directed use over time. This helps understand patient behavior and 
-- adherence patterns which is valuable for:
-- - Healthcare providers in improving preventive care recommendations
-- - Public health organizations in developing education programs
-- - Healthcare payers in understanding preventive care utilization

WITH base_metrics AS (
    -- Get core aspirin usage metrics by file date
    SELECT 
        mimi_src_file_date,
        COUNT(*) as total_respondents,
        COUNT(CASE WHEN rxq510 = 1 THEN 1 END) as provider_recommended,
        COUNT(CASE WHEN rxq515 = 1 THEN 1 END) as following_provider_advice,
        COUNT(CASE WHEN rxq520 = 1 THEN 1 END) as self_directed_use
    FROM mimi_ws_1.cdc.nhanes_qre_preventive_aspirin_use
    GROUP BY mimi_src_file_date
),

usage_details AS (
    -- Calculate percentages and ratios
    SELECT
        mimi_src_file_date,
        total_respondents,
        provider_recommended,
        following_provider_advice,
        self_directed_use,
        ROUND(100.0 * provider_recommended / total_respondents, 1) as pct_recommended,
        ROUND(100.0 * following_provider_advice / NULLIF(provider_recommended, 0), 1) as adherence_rate,
        ROUND(100.0 * self_directed_use / 
            (total_respondents - provider_recommended), 1) as self_directed_rate
    FROM base_metrics
)

SELECT 
    mimi_src_file_date as survey_date,
    total_respondents,
    pct_recommended as provider_recommendation_pct,
    adherence_rate as provider_advice_adherence_pct,
    self_directed_rate as self_directed_usage_pct,
    -- Calculate the ratio of self-directed to provider-guided use
    ROUND(CAST(self_directed_use AS FLOAT) / 
        NULLIF(following_provider_advice, 0), 2) as self_vs_provider_ratio
FROM usage_details
ORDER BY mimi_src_file_date;

-- How this query works:
-- 1. base_metrics CTE: Aggregates core counts by file date
-- 2. usage_details CTE: Calculates key percentages and metrics
-- 3. Final SELECT: Formats results and adds the self vs provider ratio

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date represents distinct survey periods
-- - Null values in rxq510, rxq515, rxq520 are treated as non-usage
-- - Does not account for dosage or frequency variations
-- - Self-directed rate calculated among those not recommended by provider

-- Possible Extensions:
-- 1. Add trend analysis across multiple periods
-- 2. Include dosage analysis (rxd530) for different usage patterns
-- 3. Add seasonal analysis if data spans multiple years
-- 4. Compare usage patterns across different data source files
-- 5. Create cohort analysis based on recommendation timing

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:33:36.873371
    - Additional Notes: Query tracks both provider-guided and self-directed aspirin usage patterns over time, calculating key ratios and adherence rates. Note that the self-directed usage rate calculation specifically excludes those with provider recommendations to avoid overlap in the metrics. Best used with multiple survey periods for trend analysis.
    
    */