-- hha_costreport_fiscal_periods.sql
-- 
-- Business Purpose: Analyze Home Health Agency fiscal reporting patterns to:
-- - Identify seasonal patterns in fiscal year choices
-- - Support financial planning and forecasting
-- - Guide optimal timing for market entry/expansion
-- - Understand industry reporting cycles for better benchmarking

WITH fiscal_metrics AS (
    -- Calculate key fiscal period metrics
    SELECT 
        EXTRACT(MONTH FROM fy_bgn_dt) AS fiscal_start_month,
        EXTRACT(MONTH FROM fy_end_dt) AS fiscal_end_month,
        YEAR(fy_bgn_dt) AS report_year,
        COUNT(DISTINCT prvdr_num) AS provider_count,
        AVG(DATEDIFF(fy_end_dt, fy_bgn_dt)) AS avg_fiscal_period_length,
        COUNT(CASE WHEN initl_rpt_sw = 'Y' THEN 1 END) AS new_reporters
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
    WHERE fy_bgn_dt IS NOT NULL 
    AND fy_end_dt IS NOT NULL
    AND fy_bgn_dt <= CURRENT_DATE()
    GROUP BY 
        fiscal_start_month,
        fiscal_end_month,
        report_year
)

SELECT 
    fiscal_start_month,
    fiscal_end_month,
    report_year,
    provider_count,
    ROUND(avg_fiscal_period_length, 1) as avg_period_days,
    new_reporters,
    ROUND(100.0 * new_reporters / provider_count, 1) as pct_new_providers,
    -- Calculate rolling 3-year growth
    provider_count - LAG(provider_count, 3) OVER (
        PARTITION BY fiscal_start_month, fiscal_end_month 
        ORDER BY report_year
    ) as three_year_growth
FROM fiscal_metrics
WHERE report_year >= 2010
ORDER BY 
    fiscal_start_month,
    fiscal_end_month,
    report_year DESC;

/* How this query works:
1. Creates a CTE to aggregate key fiscal period metrics by month and year
2. Calculates provider counts, average period lengths, and new reporter counts
3. Adds rolling metrics to identify trends
4. Filters for recent years to focus on relevant patterns

Assumptions and limitations:
- Assumes fiscal_year dates are valid and complete
- Limited to providers that submit cost reports
- New reporter flag may not capture all truly new market entrants
- Three year growth calculation requires 3 years of historical data

Possible extensions:
1. Add geographic segmentation to identify regional patterns
2. Include provider control type analysis for ownership trends
3. Incorporate payment timing analysis using fi_rcpt_dt
4. Add seasonality analysis for specific service types
5. Create forecasting models based on historical patterns
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:19:29.158114
    - Additional Notes: Query aggregates fiscal year patterns for Home Health Agencies with key metrics including period length, new entrants, and multi-year growth rates. Best used for annual planning cycles and industry trend analysis. Requires at least 3 years of historical data for complete growth metrics. Performance may be impacted with very large datasets due to window functions.
    
    */