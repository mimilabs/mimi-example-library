
/*******************************************************************************
Title: Home Health Agency Cost Report Analysis - Key Business Metrics 

Business Purpose:
This query analyzes Medicare Home Health Agency (HHA) cost report submissions 
to provide insights into:
- Reporting compliance and timeliness
- Provider control/ownership distribution  
- Year-over-year submission trends
These metrics help assess the HHA reporting landscape and identify potential 
data quality or compliance issues.

Created: 2024-02
*******************************************************************************/

WITH annual_metrics AS (
  -- Calculate key metrics by fiscal year
  SELECT 
    YEAR(fy_bgn_dt) as fiscal_year,
    COUNT(DISTINCT prvdr_num) as total_providers,
    -- Analyze provider control types
    COUNT(DISTINCT CASE WHEN prvdr_ctrl_type_cd IS NOT NULL 
          THEN prvdr_ctrl_type_cd END) as distinct_control_types,
    -- Check reporting timeliness
    AVG(DATEDIFF(fi_rcpt_dt, fy_end_dt)) as avg_days_to_submit,
    -- Track initial vs amended reports
    SUM(CASE WHEN initl_rpt_sw = 1 THEN 1 ELSE 0 END) as initial_reports,
    SUM(CASE WHEN last_rpt_sw = 1 THEN 1 ELSE 0 END) as final_reports
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
  WHERE fy_bgn_dt >= '2018-01-01' -- Focus on recent years
  GROUP BY fiscal_year
)

SELECT
  fiscal_year,
  total_providers,
  distinct_control_types,
  ROUND(avg_days_to_submit, 1) as avg_submission_days,
  initial_reports,
  final_reports,
  -- Calculate submission completion rate
  ROUND(100.0 * final_reports / NULLIF(initial_reports, 0), 1) 
    as report_completion_pct
FROM annual_metrics
ORDER BY fiscal_year DESC;

/*******************************************************************************
How this query works:
1. Creates CTE to aggregate metrics by fiscal year
2. Analyzes provider counts, control types, and reporting patterns
3. Calculates submission timeliness and completion rates
4. Returns yearly trend data ordered most recent first

Assumptions & Limitations:
- Focuses on last 5 years of data for relevance
- Assumes initl_rpt_sw and last_rpt_sw reliably indicate report status
- Does not account for provider size/volume in metrics
- May include incomplete data for most recent year

Possible Extensions:
1. Add geographic analysis by parsing provider numbers
2. Include provider size categories based on visit counts
3. Compare metrics across provider control types
4. Add quality metrics when joined with outcomes data
5. Create monthly/quarterly trend views
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:00:27.324827
    - Additional Notes: Query focuses on reporting compliance metrics and may require adjustment of the date range (currently set to 2018+) based on actual data availability. Performance could be impacted with very large datasets due to date calculations and multiple aggregations. Consider adding indexes on fy_bgn_dt and prvdr_num if query performance needs improvement.
    
    */