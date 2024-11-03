-- State Rainy Day Fund Health Score Calculation
-- Business Purpose: Calculate a composite health score for each state's rainy day fund
-- based on both absolute balance and relative percentage metrics. This helps
-- stakeholders quickly assess overall fiscal resilience while balancing different
-- measurement approaches.

WITH recent_metrics AS (
    -- Focus on the most recent complete fiscal year data
    SELECT 
        state,
        balance_in_dollars,
        percent_of_gf,
        year
    FROM mimi_ws_1.nasbo.rainy_day_fund_balances
    WHERE year = (
        SELECT MAX(year) 
        FROM mimi_ws_1.nasbo.rainy_day_fund_balances 
        WHERE balance_in_dollars IS NOT NULL
        AND percent_of_gf IS NOT NULL
    )
),

percentile_calcs AS (
    -- Calculate percentile rankings for both metrics
    SELECT
        state,
        balance_in_dollars,
        percent_of_gf,
        PERCENT_RANK() OVER (ORDER BY balance_in_dollars) AS balance_percentile,
        PERCENT_RANK() OVER (ORDER BY percent_of_gf) AS percent_percentile,
        year
    FROM recent_metrics
)

SELECT
    state,
    balance_in_dollars,
    percent_of_gf,
    -- Calculate composite health score (0-100)
    ROUND(((balance_percentile + percent_percentile) / 2) * 100, 1) as health_score,
    -- Add interpretive categories
    CASE 
        WHEN ((balance_percentile + percent_percentile) / 2) * 100 >= 75 THEN 'Strong'
        WHEN ((balance_percentile + percent_percentile) / 2) * 100 >= 50 THEN 'Moderate'
        WHEN ((balance_percentile + percent_percentile) / 2) * 100 >= 25 THEN 'Fair'
        ELSE 'Needs Attention'
    END as health_status
FROM percentile_calcs
ORDER BY health_score DESC;

-- How it works:
-- 1. Identifies most recent complete fiscal year with data
-- 2. Calculates percentile rankings for both dollar balances and GF percentages
-- 3. Combines rankings into a composite health score
-- 4. Adds interpretive categories for easy understanding
--
-- Assumptions and Limitations:
-- - Assumes both metrics are equally important (50/50 weighting)
-- - Requires complete data for both metrics
-- - Relative ranking means scores are comparative, not absolute
-- - Does not account for state-specific factors or requirements
--
-- Possible Extensions:
-- 1. Add customizable weightings for the two metrics
-- 2. Include trend analysis by comparing to prior year scores
-- 3. Incorporate additional metrics like GDP or population
-- 4. Add peer group comparisons within population or budget size bands
-- 5. Create threshold-based scoring instead of percentile-based

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:18:21.007156
    - Additional Notes: The query creates a normalized scoring system (0-100) that balances absolute and relative rainy day fund metrics. The health score calculation uses percentile rankings which means scores will always be distributed across the full range, making it more useful for comparative analysis than absolute assessment. Users should note that the scoring categories (Strong, Moderate, Fair, Needs Attention) are based on quartile distributions rather than fixed thresholds.
    
    */