-- hha_provider_profile_summary.sql
--
-- Business Purpose: Generate a snapshot profile of Home Health Agency providers to:
-- - Understand the active provider population and their reporting patterns
-- - Support provider outreach and engagement strategies
-- - Enable provider benchmarking and segmentation
-- - Inform network development and provider relations

WITH latest_reports AS (
    -- Get most recent cost report for each provider
    SELECT 
        prvdr_num,
        MAX(fy_end_dt) as latest_fy_end_dt
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
    GROUP BY prvdr_num
),

provider_profile AS (
    -- Create provider profile with key characteristics
    SELECT 
        r.prvdr_num,
        r.prvdr_ctrl_type_cd,
        COUNT(DISTINCT r.rpt_rec_num) as total_reports,
        MIN(r.fy_bgn_dt) as first_report_date,
        MAX(r.fy_end_dt) as last_report_date,
        AVG(DATEDIFF(day, r.fy_bgn_dt, r.fy_end_dt)) as avg_reporting_period_days,
        SUM(CASE WHEN r.initl_rpt_sw = '1' THEN 1 ELSE 0 END) as initial_reports_count,
        SUM(CASE WHEN r.last_rpt_sw = '1' THEN 1 ELSE 0 END) as final_reports_count
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt r
    GROUP BY r.prvdr_num, r.prvdr_ctrl_type_cd
)

SELECT 
    p.*,
    CASE 
        WHEN p.last_report_date = lr.latest_fy_end_dt THEN 'Active'
        ELSE 'Inactive'
    END as provider_status,
    DATEDIFF(year, p.first_report_date, p.last_report_date) as years_of_history,
    CASE
        WHEN total_reports >= 10 THEN 'Established'
        WHEN total_reports >= 5 THEN 'Developing'
        ELSE 'New'
    END as provider_maturity
FROM provider_profile p
JOIN latest_reports lr ON p.prvdr_num = lr.prvdr_num
ORDER BY p.total_reports DESC, p.prvdr_num;

-- How this works:
-- 1. Creates a CTE to identify the most recent cost report for each provider
-- 2. Builds provider profiles with aggregated metrics from their reporting history
-- 3. Joins and enriches with derived classifications (status, maturity)
-- 4. Orders results to highlight most established providers first

-- Assumptions & Limitations:
-- - Assumes provider numbers are consistent and unique over time
-- - Provider status logic assumes gap in reporting indicates inactivity
-- - Maturity classification thresholds are arbitrary and may need adjustment
-- - Does not account for provider mergers or acquisitions

-- Possible Extensions:
-- 1. Add geographic analysis by parsing provider numbers
-- 2. Include year-over-year growth metrics
-- 3. Add provider size classifications based on reporting volumes
-- 4. Create peer groups for benchmarking
-- 5. Add quality metrics when joined with other data sources

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:33:06.591976
    - Additional Notes: Query focuses on provider-level reporting patterns and creates categorical groupings based on reporting history. Consider adjusting maturity thresholds (5/10 reports) based on specific business needs. Provider status determination may need refinement if reporting gaps are common in the data.
    
    */