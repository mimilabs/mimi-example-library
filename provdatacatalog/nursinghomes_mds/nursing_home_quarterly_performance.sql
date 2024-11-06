-- nursing_home_financial_health_trends.sql --

-- Business Purpose: Analyze nursing home facility performance trends using quarterly measure scores 
-- to identify patterns of financial stability and potential risk areas. This helps:
-- 1. Healthcare investors assess facility performance trajectories
-- 2. Policymakers identify facilities needing support
-- 3. Administrators benchmark against peers
-- 4. Insurance companies evaluate provider network stability

WITH quarterly_trends AS (
  SELECT 
    provider_name,
    state,
    measure_code,
    measure_description,
    -- Calculate quarter-over-quarter changes
    q1_measure_score AS q1_score,
    q2_measure_score AS q2_score,
    q3_measure_score AS q3_score,
    q4_measure_score AS q4_score,
    four_quarter_average_score AS avg_score,
    -- Flag facilities with consistently declining scores
    CASE WHEN q4_measure_score < q3_measure_score 
         AND q3_measure_score < q2_measure_score 
         AND q2_measure_score < q1_measure_score 
         THEN 1 ELSE 0 END AS declining_trend_flag
  FROM mimi_ws_1.provdatacatalog.nursinghomes_mds
  WHERE measure_code IN ('NH_REHAB', 'NH_STAFFING', 'NH_EXPENSES')
    AND four_quarter_average_score IS NOT NULL
)

SELECT 
  state,
  measure_description,
  COUNT(DISTINCT provider_name) as facility_count,
  ROUND(AVG(avg_score),2) as avg_annual_score,
  ROUND(AVG(q4_score) - AVG(q1_score),2) as avg_yearly_change,
  SUM(declining_trend_flag) as facilities_with_decline,
  ROUND(AVG(CASE WHEN declining_trend_flag = 1 THEN avg_score END),2) as declining_facilities_avg_score
FROM quarterly_trends
GROUP BY state, measure_description
HAVING COUNT(DISTINCT provider_name) >= 5
ORDER BY state, measure_description;

-- How it works:
-- 1. CTE creates a clean view of quarterly scores and identifies declining trends
-- 2. Main query aggregates by state and measure to show:
--    - Overall facility counts and averages
--    - Year-over-year changes
--    - Number of facilities showing consistent decline
--    - Average scores of declining facilities

-- Assumptions & Limitations:
-- 1. Assumes measure codes NH_REHAB, NH_STAFFING, NH_EXPENSES exist and are relevant
-- 2. Requires at least 5 facilities per state/measure for meaningful analysis
-- 3. Missing quarterly data may affect trend calculations
-- 4. Does not account for seasonal variations

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify regional patterns
-- 2. Include facility size or ownership type stratification
-- 3. Create risk scoring based on trend severity and persistence
-- 4. Add peer group comparisons within similar market sizes
-- 5. Incorporate quality measures correlation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:16:42.010403
    - Additional Notes: Query requires validation of measure codes (NH_REHAB, NH_STAFFING, NH_EXPENSES) as these appear to be example codes and may need to be replaced with actual measure codes from the dataset. The 5-facility minimum threshold per state may need adjustment based on specific analysis needs.
    
    */