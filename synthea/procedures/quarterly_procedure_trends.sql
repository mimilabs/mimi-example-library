-- Title: Seasonal Procedure Volume Analysis for Capacity Planning
-- 
-- Business Purpose:
-- - Analyze quarterly procedure volumes to identify seasonal patterns
-- - Support staffing and resource allocation decisions 
-- - Enable proactive scheduling during peak periods
-- - Improve patient access by matching capacity to demand patterns
--

WITH quarterly_volumes AS (
  -- Get procedure counts by quarter and description
  SELECT 
    DATE_TRUNC('quarter', date) as procedure_quarter,
    description as procedure_name,
    COUNT(*) as procedure_count
  FROM mimi_ws_1.synthea.procedures
  WHERE date >= DATE_SUB(CURRENT_DATE, 730) -- Look at last 2 years
  GROUP BY 1, 2
),

ranked_procedures AS (
  -- Identify top procedures by volume
  SELECT procedure_name,
    SUM(procedure_count) as total_procedures
  FROM quarterly_volumes
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 5
)

-- Final output showing quarterly trends for top procedures
SELECT 
  qv.procedure_quarter,
  qv.procedure_name,
  qv.procedure_count,
  ROUND(100.0 * qv.procedure_count / LAG(qv.procedure_count) 
    OVER (PARTITION BY qv.procedure_name ORDER BY qv.procedure_quarter) - 100, 1) 
    as qtr_over_qtr_pct_change
FROM quarterly_volumes qv
INNER JOIN ranked_procedures rp 
  ON qv.procedure_name = rp.procedure_name
ORDER BY qv.procedure_quarter, qv.procedure_count DESC;

-- How this query works:
-- 1. Creates quarterly aggregations of procedure volumes
-- 2. Identifies top 5 procedures by total volume
-- 3. Calculates quarter-over-quarter percent changes
-- 4. Joins and filters to show trends for just the top procedures

-- Assumptions & Limitations:
-- - Requires at least 2 years of historical data
-- - Focuses only on procedure volumes, not complexity or resources needed
-- - Quarter-over-quarter changes may be affected by calendar artifacts
-- - Limited to top 5 procedures for clarity

-- Possible Extensions:
-- 1. Add facility/location dimension to support local planning
-- 2. Include procedure duration estimates for capacity modeling
-- 3. Incorporate historical staffing levels for correlation analysis
-- 4. Add confidence intervals for volume predictions
-- 5. Break down by procedure type (surgical vs. diagnostic)
-- 6. Include day-of-week patterns within quarters

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:08:02.033053
    - Additional Notes: Query is optimized for quarterly operational planning cycles and assumes a minimum of 2 years historical data is available. The 730-day lookback period may need adjustment based on specific planning needs. Consider memory usage if analyzing a large number of facilities or extended time periods.
    
    */