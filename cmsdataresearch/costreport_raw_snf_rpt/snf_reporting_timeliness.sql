-- snf_fiscal_capacity.sql --
-- Business Purpose: --
-- Analyze the fiscal reporting completeness and timeliness of SNFs to evaluate
-- operational capacity and compliance. This helps identify facilities that may need
-- additional support or oversight, and reveals broader industry reporting patterns.

-- Main Query --
WITH reporting_metrics AS (
    SELECT 
        EXTRACT(YEAR FROM fy_end_dt) as report_year,
        -- Calculate days between key reporting dates
        AVG(DATEDIFF(fi_rcpt_dt, fy_end_dt)) as avg_days_to_submit,
        -- Count reports by status
        COUNT(DISTINCT prvdr_num) as total_facilities,
        COUNT(CASE WHEN rpt_stus_cd = 'F' THEN 1 END) as final_reports,
        COUNT(CASE WHEN initl_rpt_sw = 'Y' THEN 1 END) as initial_reports
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_rpt
    WHERE fy_end_dt IS NOT NULL 
    AND EXTRACT(YEAR FROM fy_end_dt) BETWEEN 2015 AND 2023
    GROUP BY EXTRACT(YEAR FROM fy_end_dt)
)

SELECT 
    report_year,
    total_facilities,
    avg_days_to_submit,
    final_reports,
    initial_reports,
    ROUND((final_reports * 100.0 / total_facilities), 2) as pct_final_complete,
    ROUND((initial_reports * 100.0 / total_facilities), 2) as pct_initial_complete
FROM reporting_metrics
ORDER BY report_year DESC;

-- How it works:
-- 1. Creates a CTE to aggregate key reporting metrics by fiscal year
-- 2. Calculates average submission timelines and report status counts
-- 3. Computes completion percentages for initial and final reports
-- 4. Returns a year-over-year view of reporting patterns

-- Assumptions & Limitations:
-- - Requires valid fy_end_dt values for year extraction
-- - Limited to recent years (2015-2023) for relevance
-- - Relies on accurate status codes and date fields
-- - Does not account for amended reports or resubmissions

-- Possible Extensions:
-- 1. Add geographic analysis by joining with facility location data
-- 2. Include trend analysis with year-over-year change calculations
-- 3. Incorporate vendor analysis to identify submission patterns by adr_vndr_cd
-- 4. Add seasonality analysis of submission timing within fiscal years
-- 5. Create facility risk scoring based on reporting patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:40:41.476246
    - Additional Notes: This query focuses on measuring reporting compliance and efficiency metrics across SNFs. The key metrics include submission delays, completion rates, and the balance between initial and final reports. Note that the accuracy depends heavily on the proper recording of report status codes and submission dates in the source data.
    
    */