-- hha_costreport_ownership_analysis.sql
-- Business Purpose: Analyze Home Health Agency ownership distribution and reporting patterns to:
-- - Identify market consolidation trends
-- - Track changes in ownership types over time
-- - Support market entry and competitive analysis decisions
-- - Inform strategic partnership opportunities

WITH provider_summary AS (
  -- Get latest report for each provider to avoid duplicates
  SELECT 
    prvdr_num,
    prvdr_ctrl_type_cd,
    YEAR(fy_end_dt) as report_year,
    ROW_NUMBER() OVER (PARTITION BY prvdr_num, YEAR(fy_end_dt) ORDER BY fy_end_dt DESC) as rn
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
  WHERE fy_end_dt >= '2018-01-01'
  AND rpt_stus_cd = 'F' -- Only final reports
),

ownership_trends AS (
  -- Calculate ownership type distributions and year-over-year changes
  SELECT
    report_year,
    prvdr_ctrl_type_cd,
    COUNT(DISTINCT prvdr_num) as provider_count,
    ROUND(COUNT(DISTINCT prvdr_num) * 100.0 / SUM(COUNT(DISTINCT prvdr_num)) OVER (PARTITION BY report_year), 2) as pct_of_total
  FROM provider_summary 
  WHERE rn = 1
  GROUP BY report_year, prvdr_ctrl_type_cd
)

SELECT 
  report_year,
  prvdr_ctrl_type_cd as ownership_type,
  provider_count,
  pct_of_total as market_share_pct,
  provider_count - LAG(provider_count, 1) OVER (PARTITION BY prvdr_ctrl_type_cd ORDER BY report_year) as yoy_change_count
FROM ownership_trends
ORDER BY report_year DESC, market_share_pct DESC;

/* How this query works:
1. Creates provider_summary CTE to get latest report for each provider per year
2. Creates ownership_trends CTE to calculate market share metrics
3. Final SELECT adds year-over-year change calculations
4. Results show ownership distribution trends over time

Assumptions and Limitations:
- Uses only final status reports ('F') to ensure data quality
- Limited to recent years (2018+) for relevance
- Assumes provider numbers remain consistent across years
- Control type codes require reference data for interpretation

Possible Extensions:
1. Add geographic analysis by joining with provider location data
2. Include revenue or visit volume metrics to weight market share
3. Add ownership change detection by tracking control type changes
4. Create forecasting model for ownership trend projections
5. Add filters for specific states or metropolitan areas
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:10:23.056586
    - Additional Notes: Query focuses on HHA market structure analysis through ownership types, supporting strategic decision-making. Results show ownership distribution and year-over-year changes since 2018. Best used in conjunction with reference data for control type code interpretation.
    
    */