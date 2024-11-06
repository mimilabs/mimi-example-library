-- hha_costreport_longevity_analysis.sql 

-- Business Purpose: Analyze Home Health Agency operational longevity and sustainability by:
-- - Identifying long-running vs recently established providers
-- - Tracking provider lifecycle patterns
-- - Supporting market stability assessment
-- - Informing provider risk profiling

-- Main Query
WITH provider_history AS (
  SELECT 
    prvdr_num,
    MIN(fy_bgn_dt) as first_report_date,
    MAX(fy_end_dt) as last_report_date,
    COUNT(DISTINCT rpt_rec_num) as total_reports,
    DATEDIFF(MAX(fy_end_dt), MIN(fy_bgn_dt))/365.25 as years_active
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
  WHERE rpt_stus_cd NOT IN ('W','X') -- Exclude withdrawn/deleted reports
  GROUP BY prvdr_num
),

longevity_segments AS (
  SELECT 
    CASE 
      WHEN years_active >= 10 THEN 'Established (10+ years)'
      WHEN years_active >= 5 THEN 'Mature (5-10 years)'
      WHEN years_active >= 2 THEN 'Growing (2-5 years)'
      ELSE 'New (<2 years)'
    END as provider_segment,
    COUNT(*) as provider_count,
    AVG(total_reports) as avg_reports_submitted,
    MIN(first_report_date) as segment_earliest_entry,
    MAX(last_report_date) as segment_latest_activity
  FROM provider_history
  GROUP BY 1
)

SELECT 
  provider_segment,
  provider_count,
  ROUND(provider_count * 100.0 / SUM(provider_count) OVER(), 1) as pct_of_total,
  ROUND(avg_reports_submitted, 1) as avg_reports_submitted,
  segment_earliest_entry,
  segment_latest_activity
FROM longevity_segments
ORDER BY provider_count DESC;

/* How it works:
1. First CTE establishes provider history timeline using fiscal year dates
2. Second CTE segments providers into longevity categories
3. Final query calculates market composition metrics

Assumptions & Limitations:
- Assumes continuous operation between first and last report dates
- Does not account for ownership changes or provider number reassignments
- Limited to providers who have submitted cost reports
- Historical completeness depends on data retention policies

Possible Extensions:
1. Add geographic analysis to identify regions with higher provider stability
2. Include provider control type to analyze ownership impact on longevity
3. Track year-over-year changes in provider segment distributions
4. Add financial metrics correlation with provider longevity
5. Build predictive models for provider sustainability risk
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:25:40.657965
    - Additional Notes: Query focuses on operational continuity metrics using fiscal year dates and report submissions. May need adjustment for datasets with incomplete historical records or providers with multiple provider numbers due to ownership changes.
    
    */