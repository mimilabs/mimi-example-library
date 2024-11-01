-- Title: Provider Deactivation Temporal Analysis
-- 
-- Business Purpose:
-- - Track the volume and timing of provider deactivations
-- - Identify seasonal patterns or unusual spikes in deactivations
-- - Support compliance monitoring and risk assessment
--
-- Note: This analysis focuses solely on the deactivated table without joins
-- since the npi_enumeration table is not available

WITH monthly_stats AS (
    -- Calculate monthly deactivation counts and running totals
    SELECT 
        DATE_TRUNC('month', deactivation_date) as month,
        COUNT(*) as monthly_deactivations,
        SUM(COUNT(*)) OVER (ORDER BY DATE_TRUNC('month', deactivation_date)) as cumulative_deactivations,
        LAG(COUNT(*), 1) OVER (ORDER BY DATE_TRUNC('month', deactivation_date)) as previous_month_count
    FROM mimi_ws_1.nppes.deactivated
    WHERE deactivation_date >= DATE_SUB(CURRENT_DATE, 730) -- Last 2 years
    GROUP BY DATE_TRUNC('month', deactivation_date)
),

monthly_changes AS (
    -- Calculate month-over-month changes
    SELECT 
        month,
        monthly_deactivations,
        cumulative_deactivations,
        CASE 
            WHEN previous_month_count IS NULL THEN 0
            ELSE ROUND(((monthly_deactivations - previous_month_count) / previous_month_count) * 100, 1)
        END as month_over_month_change
    FROM monthly_stats
)

-- Final output with insights
SELECT 
    month,
    monthly_deactivations,
    cumulative_deactivations,
    month_over_month_change,
    CASE 
        WHEN month_over_month_change > 50 THEN 'Significant Increase'
        WHEN month_over_month_change < -50 THEN 'Significant Decrease'
        ELSE 'Normal Variation'
    END as variation_category
FROM monthly_changes
ORDER BY month DESC;

-- How this query works:
-- 1. Groups deactivations by month and calculates monthly totals
-- 2. Computes running totals of deactivations over time
-- 3. Calculates month-over-month percentage changes
-- 4. Flags significant variations in deactivation patterns
--
-- Assumptions and limitations:
-- - Limited to last 2 years of data
-- - Assumes deactivation_date is consistently populated
-- - Month-over-month comparisons may be affected by holidays/weekends
-- - Does not account for total provider population changes
--
-- Possible extensions:
-- 1. Add weekly analysis for more granular patterns
-- 2. Include year-over-year comparisons
-- 3. Add moving averages to smooth seasonal variations
-- 4. Calculate weighted scores for trend analysis
-- 5. Add forecasting for expected deactivation volumes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:42:32.347004
    - Additional Notes: Query focuses on temporal patterns of provider deactivations using a 2-year lookback period. Highlights significant month-over-month variations (>50% change) and tracks cumulative deactivation counts. Best used for identifying unusual spikes or drops in deactivation rates that may warrant further investigation.
    
    */