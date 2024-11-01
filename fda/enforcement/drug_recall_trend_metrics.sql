-- recall_trend_analysis.sql
-- Business Purpose:
-- - Track and analyze drug recall trends over time to identify emerging safety patterns
-- - Support proactive risk monitoring and early warning systems
-- - Aid in resource planning for regulatory response teams
-- - Provide insights for policy and process improvements

WITH monthly_recalls AS (
    SELECT 
        DATE_TRUNC('month', report_date) AS month,
        classification,
        COUNT(*) as recall_count,
        COUNT(DISTINCT recalling_firm) as unique_firms,
        -- Calculate % voluntary vs mandated
        ROUND(100.0 * COUNT(CASE WHEN voluntary_mandated = 'Voluntary' THEN 1 END) / COUNT(*), 1) as voluntary_pct
    FROM mimi_ws_1.fda.enforcement
    WHERE report_date >= DATE_ADD(months, -24, CURRENT_DATE) -- Focus on last 24 months
    GROUP BY 1, 2
)

SELECT 
    month,
    classification,
    recall_count,
    unique_firms,
    voluntary_pct,
    -- Calculate 3-month moving average to smooth trends
    ROUND(AVG(recall_count) OVER (
        PARTITION BY classification 
        ORDER BY month 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 1) as three_month_avg
FROM monthly_recalls
ORDER BY month DESC, classification;

-- How this query works:
-- 1. Creates monthly aggregation of recalls with key metrics
-- 2. Calculates 3-month moving average to identify trends
-- 3. Shows breakdown by classification (severity level)
-- 4. Includes both volume metrics and participation metrics (unique firms)

-- Assumptions and Limitations:
-- - Assumes report_date is the best indicator of recall timing
-- - Limited to last 24 months of data for trend focus
-- - Moving average uses simple 3-month window
-- - Does not account for recall duration or impact scope

-- Possible Extensions:
-- 1. Add year-over-year comparison
-- 2. Include seasonal adjustment factors
-- 3. Break down by reason categories
-- 4. Add prediction intervals for trend forecasting
-- 5. Create alerts for significant deviations from baseline
-- 6. Include product quantity in volume calculations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:06:19.944693
    - Additional Notes: Query provides key monitoring metrics for drug recalls including volume trends, firm participation rates, and recall classification patterns. The 24-month window and 3-month moving average are configurable parameters that can be adjusted based on monitoring needs. Results are most effective when reviewed monthly to identify emerging patterns.
    
    */