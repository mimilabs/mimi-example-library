-- geographic_payment_concentration.sql
-- Business Purpose:
-- Analyze the geographic concentration of healthcare industry payments to identify
-- high-value regions and potential market opportunities. This helps:
-- - Target sales and marketing efforts in high-value areas
-- - Identify underserved markets for expansion
-- - Support market access and payer strategy decisions
-- - Inform territory planning and resource allocation

WITH payment_by_state AS (
    -- Aggregate payments by state and recipient type
    SELECT 
        recipient_state,
        covered_recipient_type,
        COUNT(DISTINCT covered_recipient_profile_id) as unique_recipients,
        COUNT(*) as total_transactions,
        SUM(total_amount_of_payment_us_dollars) as total_payment_amount,
        AVG(total_amount_of_payment_us_dollars) as avg_payment_amount
    FROM mimi_ws_1.openpayments.general
    WHERE recipient_state IS NOT NULL 
    AND program_year >= YEAR(CURRENT_DATE) - 2  -- Focus on recent years
    GROUP BY recipient_state, covered_recipient_type
),

state_rankings AS (
    -- Calculate rankings and percentiles for each state
    SELECT 
        recipient_state,
        covered_recipient_type,
        unique_recipients,
        total_transactions,
        total_payment_amount,
        avg_payment_amount,
        RANK() OVER (PARTITION BY covered_recipient_type ORDER BY total_payment_amount DESC) as payment_rank,
        PERCENT_RANK() OVER (PARTITION BY covered_recipient_type ORDER BY total_payment_amount) as payment_percentile
    FROM payment_by_state
)

-- Final output with key market indicators
SELECT 
    recipient_state,
    covered_recipient_type,
    unique_recipients,
    total_transactions,
    ROUND(total_payment_amount, 2) as total_payment_amount,
    ROUND(avg_payment_amount, 2) as avg_payment_amount,
    payment_rank,
    ROUND(payment_percentile * 100, 1) as market_penetration_percentile,
    CASE 
        WHEN payment_percentile >= 0.75 THEN 'High Value Market'
        WHEN payment_percentile >= 0.5 THEN 'Developed Market'
        WHEN payment_percentile >= 0.25 THEN 'Growing Market'
        ELSE 'Emerging Market'
    END as market_classification
FROM state_rankings
ORDER BY covered_recipient_type, payment_rank;

-- How it works:
-- 1. Aggregates payment data by state and recipient type
-- 2. Calculates key metrics: unique recipients, transaction volume, payment amounts
-- 3. Ranks states based on total payments and assigns market classifications
-- 4. Provides clear market indicators for strategic decision making

-- Assumptions and Limitations:
-- - Uses state-level aggregation (may mask local market variations)
-- - Focuses on recent years only (historical trends not included)
-- - Assumes payment amounts are primary indicator of market value
-- - Does not account for population differences between states

-- Possible Extensions:
-- 1. Add year-over-year growth rates for trend analysis
-- 2. Include population-adjusted metrics (payments per capita)
-- 3. Break down by specific payment types or product categories
-- 4. Add geographic clustering analysis for regional patterns
-- 5. Include seasonal payment patterns analysis
-- 6. Incorporate demographic and economic indicators by state

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:33:53.656769
    - Additional Notes: Query focuses on geographic market analysis for healthcare payments, providing insights for market strategy and resource allocation. Performance may be impacted with large datasets due to window functions. Consider partitioning by program_year for better performance when analyzing multiple years.
    
    */