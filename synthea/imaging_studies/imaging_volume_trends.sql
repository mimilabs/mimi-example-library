-- Title: Imaging Utilization Time Trends Analysis
-- Business Purpose: Track the temporal patterns of imaging studies to identify
-- peak periods, workload distribution, and capacity planning needs.
-- This analysis helps healthcare organizations optimize staffing,
-- equipment utilization, and resource allocation.

WITH daily_volumes AS (
    -- Calculate daily imaging volumes and running 7-day average
    SELECT 
        DATE_TRUNC('day', date) as study_date,
        COUNT(*) as daily_count,
        AVG(COUNT(*)) OVER (
            ORDER BY DATE_TRUNC('day', date)
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as rolling_7day_avg
    FROM mimi_ws_1.synthea.imaging_studies
    GROUP BY DATE_TRUNC('day', date)
),
monthly_summary AS (
    -- Aggregate to monthly level with year-over-year comparison
    SELECT 
        DATE_TRUNC('month', study_date) as month_date,
        SUM(daily_count) as monthly_volume,
        LAG(SUM(daily_count), 12) OVER (ORDER BY DATE_TRUNC('month', study_date)) as prev_year_volume,
        AVG(rolling_7day_avg) as avg_daily_volume
    FROM daily_volumes
    GROUP BY DATE_TRUNC('month', study_date)
)

SELECT 
    month_date,
    monthly_volume,
    prev_year_volume,
    avg_daily_volume,
    CASE 
        WHEN prev_year_volume IS NOT NULL 
        THEN ROUND(((monthly_volume - prev_year_volume) / prev_year_volume * 100), 1)
        ELSE NULL 
    END as yoy_growth_pct,
    ROUND(avg_daily_volume, 1) as avg_daily_volume_rounded
FROM monthly_summary
WHERE month_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '24 months')
ORDER BY month_date DESC;

-- How it works:
-- 1. First CTE calculates daily volumes and a 7-day rolling average
-- 2. Second CTE aggregates to monthly level and calculates year-over-year comparisons
-- 3. Final query formats results and limits to last 24 months
--
-- Assumptions and Limitations:
-- - Assumes data completeness for accurate trending
-- - Rolling averages at period boundaries may be based on fewer days
-- - Year-over-year calculations require at least 13 months of data
--
-- Possible Extensions:
-- 1. Add day-of-week analysis to identify weekly patterns
-- 2. Include modality-specific trends to track equipment utilization
-- 3. Incorporate seasonality adjustments for more accurate forecasting
-- 4. Add statistical anomaly detection for unusual volume patterns
-- 5. Calculate peak hour distribution for staffing optimization

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:26:32.308820
    - Additional Notes: Query requires at least 13 months of historical data for year-over-year comparisons. The 7-day rolling average calculation may be incomplete at the edges of the date range. Performance may degrade with very large datasets due to window functions.
    
    */