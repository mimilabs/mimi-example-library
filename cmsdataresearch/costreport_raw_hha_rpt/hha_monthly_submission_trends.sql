-- hha_monthly_reporting_volume.sql

-- Business Purpose: Analyze monthly cost report submission volumes to:
-- - Track operational workload patterns for review staff
-- - Identify peak submission periods requiring additional resources
-- - Support capacity planning and staffing decisions
-- - Monitor year-over-year growth in submission volume

WITH monthly_submissions AS (
    -- Calculate submissions by month and year
    SELECT 
        DATE_TRUNC('month', fi_rcpt_dt) AS submission_month,
        COUNT(*) AS total_submissions,
        COUNT(DISTINCT prvdr_num) AS unique_providers,
        -- Calculate percentage of initial vs amended reports
        SUM(CASE WHEN initl_rpt_sw = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS pct_initial_reports
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
    WHERE fi_rcpt_dt IS NOT NULL 
        AND fi_rcpt_dt >= '2018-01-01' -- Focus on recent 5 years
        AND fi_rcpt_dt < CURRENT_DATE
    GROUP BY DATE_TRUNC('month', fi_rcpt_dt)
),

year_over_year AS (
    -- Calculate year-over-year growth rates
    SELECT 
        submission_month,
        total_submissions,
        unique_providers,
        pct_initial_reports,
        LAG(total_submissions, 12) OVER (ORDER BY submission_month) AS prev_year_submissions,
        CASE 
            WHEN LAG(total_submissions, 12) OVER (ORDER BY submission_month) > 0 
            THEN ((total_submissions - LAG(total_submissions, 12) OVER (ORDER BY submission_month)) * 100.0 / 
                  LAG(total_submissions, 12) OVER (ORDER BY submission_month))
            ELSE NULL 
        END AS yoy_growth_rate
    FROM monthly_submissions
)

SELECT 
    submission_month,
    total_submissions,
    unique_providers,
    ROUND(pct_initial_reports, 1) AS pct_initial_reports,
    prev_year_submissions,
    ROUND(yoy_growth_rate, 1) AS yoy_growth_rate
FROM year_over_year
ORDER BY submission_month DESC;

-- How it works:
-- 1. First CTE aggregates submissions by month, counting total and unique providers
-- 2. Second CTE calculates year-over-year growth rates using LAG function
-- 3. Final output provides monthly trending with YoY comparisons

-- Assumptions & Limitations:
-- - Requires valid fi_rcpt_dt values for accurate counting
-- - Growth rates start appearing after first 12 months of data
-- - Does not account for holidays or business days
-- - May include resubmissions and corrections

-- Possible Extensions:
-- 1. Add weekly or daily granularity for detailed workload analysis
-- 2. Include geographic breakdown by state or region
-- 3. Compare submission patterns across provider control types
-- 4. Add moving averages to smooth seasonal variations
-- 5. Incorporate report complexity metrics (e.g., size of provider)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:49:20.306382
    - Additional Notes: The query focuses on operational workload patterns by analyzing submission volumes. It requires at least 13 months of historical data to generate meaningful year-over-year comparisons. The default 5-year lookback period (2018+) can be adjusted based on analysis needs.
    
    */