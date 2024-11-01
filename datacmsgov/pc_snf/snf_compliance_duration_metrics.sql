-- Title: SNF Medicare Enrollment Duration and Compliance Analysis

-- Business Purpose:
-- This analysis examines the Medicare enrollment compliance and longevity patterns of SNFs by:
-- 1. Identifying facilities with potential compliance gaps (missing CCNs or NPIs)
-- 2. Analyzing the time between incorporation and current operation
-- 3. Highlighting facilities requiring additional documentation verification
-- 4. Supporting regulatory oversight and compliance monitoring efforts

WITH compliance_metrics AS (
  SELECT 
    s.enrollment_state,
    COUNT(*) as total_facilities,
    -- Calculate compliance indicators
    SUM(CASE WHEN s.ccn IS NULL THEN 1 ELSE 0 END) as missing_ccn_count,
    SUM(CASE WHEN s.npi IS NULL THEN 1 ELSE 0 END) as missing_npi_count,
    -- Calculate operational duration
    AVG(DATEDIFF(CURRENT_DATE(), s.incorporation_date)) as avg_days_since_incorporation,
    -- Identify documentation patterns
    COUNT(DISTINCT s.organization_type_structure) as org_type_count
  FROM mimi_ws_1.datacmsgov.pc_snf s
  WHERE s.mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.pc_snf)
  GROUP BY s.enrollment_state
)

SELECT 
  cm.enrollment_state,
  cm.total_facilities,
  cm.missing_ccn_count,
  cm.missing_npi_count,
  -- Calculate compliance percentages
  ROUND(100.0 * cm.missing_ccn_count / cm.total_facilities, 2) as pct_missing_ccn,
  ROUND(100.0 * cm.missing_npi_count / cm.total_facilities, 2) as pct_missing_npi,
  -- Convert days to years for better readability
  ROUND(cm.avg_days_since_incorporation / 365.25, 1) as avg_years_operating,
  cm.org_type_count as distinct_org_types
FROM compliance_metrics cm
WHERE cm.total_facilities >= 10  -- Focus on states with meaningful sample sizes
ORDER BY cm.total_facilities DESC;

-- How the Query Works:
-- 1. Creates a CTE to calculate key compliance and operational metrics by state
-- 2. Uses the most recent data snapshot via mimi_src_file_date
-- 3. Calculates both absolute counts and percentages for compliance gaps
-- 4. Converts operational duration to years for better business interpretation
-- 5. Filters for states with at least 10 facilities for statistical relevance

-- Assumptions and Limitations:
-- 1. Assumes current snapshot represents active Medicare enrollment status
-- 2. Missing CCN/NPI could indicate either compliance issues or data quality problems
-- 3. Incorporation date might not exactly match Medicare enrollment date
-- 4. State-level aggregation may mask facility-specific issues

-- Possible Extensions:
-- 1. Add trend analysis by comparing metrics across multiple mimi_src_file_dates
-- 2. Include ownership type analysis to correlate with compliance patterns
-- 3. Add geographic clustering analysis to identify regional compliance patterns
-- 4. Incorporate facility size metrics to analyze compliance by facility scale
-- 5. Add comparison with industry benchmarks or regulatory thresholds

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:09:42.463958
    - Additional Notes: Query focuses on regulatory compliance indicators and facility longevity, filtering out states with fewer than 10 facilities to ensure statistical significance. Results are normalized to percentages and years for easier business interpretation. Consider state-specific regulatory requirements when interpreting results.
    
    */