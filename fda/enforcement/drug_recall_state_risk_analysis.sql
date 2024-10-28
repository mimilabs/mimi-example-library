
-- drug_recall_geographic_impact.sql
/*
Business Purpose:
Analyze the geographic distribution and impact of drug recalls to help:
1. Identify high-risk regions requiring increased oversight
2. Support resource allocation for regulatory compliance monitoring
3. Enable targeted outreach to affected areas

This query provides insights into recall volumes and severity by state/region
to support risk-based inspection planning and compliance monitoring.
*/

-- Main analysis of recall geographic patterns and severity
WITH recall_locations AS (
  -- Get distinct locations affected by recalls
  SELECT DISTINCT 
    state,
    distribution_pattern,
    classification,
    recall_number,
    report_date,
    recalling_firm
  FROM mimi_ws_1.fda.enforcement
  WHERE state IS NOT NULL
    AND report_date >= add_months(current_date(), -60) -- Look back 5 years
),

state_metrics AS (
  -- Calculate key metrics by state
  SELECT
    state,
    COUNT(DISTINCT recall_number) as total_recalls,
    COUNT(DISTINCT CASE WHEN classification = 'Class I' THEN recall_number END) as class_1_recalls,
    COUNT(DISTINCT recalling_firm) as unique_firms,
    -- Calculate percentage of recalls that are Class I (most severe)
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN classification = 'Class I' THEN recall_number END) / 
          NULLIF(COUNT(DISTINCT recall_number),0), 1) as pct_class_1
  FROM recall_locations
  GROUP BY state
)

SELECT 
  state,
  total_recalls,
  class_1_recalls,
  unique_firms,
  pct_class_1,
  -- Add ranking to identify highest risk states
  RANK() OVER (ORDER BY total_recalls DESC) as recall_volume_rank,
  RANK() OVER (ORDER BY pct_class_1 DESC) as severity_rank
FROM state_metrics
WHERE total_recalls >= 5  -- Filter for states with meaningful sample size
ORDER BY total_recalls DESC, pct_class_1 DESC;

/*
How it works:
1. First CTE gets distinct recall events with location info
2. Second CTE calculates key metrics per state
3. Final query adds rankings and filters for meaningful analysis

Assumptions & Limitations:
- Uses state of recalling firm as proxy for impact location
- Distribution patterns may cross state boundaries
- Some recalls may not have state information
- Limited to last 5 years of data using add_months() instead of date_sub()

Possible Extensions:
1. Add temporal analysis to show trending by region
2. Include distribution pattern analysis for multi-state impact
3. Add product category breakdown by region
4. Incorporate population normalization for per-capita analysis
5. Create risk score combining volume and severity metrics
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:21:20.166926
    - Additional Notes: Query provides state-level risk assessment metrics for drug recalls over a 5-year period. Results include total recall counts, Class I (severe) recall percentages, and state rankings by both volume and severity. Useful for regulatory oversight and resource allocation planning. Note that analysis is based on recalling firm location rather than full distribution patterns.
    
    */