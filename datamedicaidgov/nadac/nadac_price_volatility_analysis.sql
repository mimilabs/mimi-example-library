-- NADAC Drug Pricing Stability Analysis
--
-- Business Purpose:
-- This query analyzes the stability and reliability of NADAC drug pricing data to:
-- 1. Identify drugs with frequent price changes
-- 2. Assess data quality and reporting patterns
-- 3. Support pharmacy reimbursement planning by understanding price volatility
--
-- The analysis helps payers and PBMs understand pricing reliability for contracting
-- and rate-setting purposes.

WITH price_changes AS (
    -- Calculate price changes and reporting patterns by NDC
    SELECT 
        ndc,
        ndc_description,
        classification_for_rate_setting,
        COUNT(DISTINCT nadac_per_unit) as unique_price_points,
        COUNT(DISTINCT effective_date) as price_updates,
        MIN(effective_date) as first_reported_date,
        MAX(effective_date) as last_reported_date,
        COUNT(DISTINCT explanation_code) as different_calc_methods,
        MAX(nadac_per_unit) as highest_price,
        MIN(nadac_per_unit) as lowest_price,
        AVG(nadac_per_unit) as avg_price
    FROM mimi_ws_1.datamedicaidgov.nadac
    WHERE effective_date >= '2022-01-01'  -- Focus on recent data
    GROUP BY 1,2,3
),

volatility_metrics AS (
    -- Calculate price volatility metrics
    SELECT 
        *,
        DATEDIFF(DAY, first_reported_date, last_reported_date) as days_monitored,
        (highest_price - lowest_price) / NULLIF(avg_price, 0) * 100 as price_variation_pct,
        price_updates / NULLIF(DATEDIFF(DAY, first_reported_date, last_reported_date), 0) * 30 as updates_per_month
    FROM price_changes
    WHERE DATEDIFF(DAY, first_reported_date, last_reported_date) >= 90  -- Minimum monitoring period
)

SELECT 
    ndc,
    ndc_description,
    classification_for_rate_setting,
    unique_price_points,
    price_updates,
    different_calc_methods,
    ROUND(price_variation_pct, 1) as price_variation_pct,
    ROUND(updates_per_month, 2) as updates_per_month,
    ROUND(avg_price, 2) as avg_price,
    days_monitored
FROM volatility_metrics
WHERE price_variation_pct > 10  -- Focus on products with significant variation
ORDER BY price_variation_pct DESC, updates_per_month DESC
LIMIT 100;

-- How it works:
-- 1. First CTE aggregates pricing history metrics by NDC
-- 2. Second CTE calculates volatility measures
-- 3. Final query filters and presents most volatile products
--
-- Assumptions and Limitations:
-- - Requires at least 90 days of price history
-- - Focuses on products with >10% price variation
-- - Does not account for seasonal patterns
-- - May include both active and discontinued products
--
-- Possible Extensions:
-- 1. Add therapeutic class analysis
-- 2. Compare volatility patterns between brands and generics
-- 3. Analyze explanation code patterns for volatile products
-- 4. Add market share or utilization data to prioritize findings
-- 5. Create time-based volatility trends

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:06:15.296301
    - Additional Notes: The query filters for drugs with more than 10% price variation and requires at least 90 days of pricing history. Results are limited to top 100 most volatile drugs. Price updates frequency is normalized to monthly basis to enable fair comparison across different monitoring periods.
    
    */