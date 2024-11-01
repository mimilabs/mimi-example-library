-- TITLE: HHA Cost Evolution and Operating Model Analysis

-- BUSINESS PURPOSE:
-- Analyze the operational cost trends and service delivery models of home health agencies to understand:
-- - Cost per visit trends over time
-- - Resource allocation across different service types
-- - Operating efficiency metrics
-- - Relationship between size and cost efficiency
-- This helps identify best practices, opportunities for efficiency gains, and sustainable operating models.

WITH yearly_metrics AS (
  SELECT 
    YEAR(fiscal_year_begin_date) AS fiscal_year,
    
    -- Calculate key efficiency metrics
    AVG(skilled_nursing_carern_avg_cost_per_visit) AS avg_rn_cost_per_visit,
    AVG(home_health_aide_avg_cost_per_visit) AS avg_aide_cost_per_visit,
    
    -- Calculate service mix percentages
    SUM(skilled_nursing_carern_total_visits) AS total_rn_visits,
    SUM(home_health_aide_total_visits) AS total_aide_visits,
    SUM(total_total_visits) AS total_visits,
    
    -- Operating metrics
    AVG(less_total_operating_expenses_sum_of_lines_4_through_16) AS avg_operating_expense,
    COUNT(DISTINCT provider_ccn) AS provider_count

  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hha
  WHERE fiscal_year_begin_date >= '2015-01-01' 
    AND skilled_nursing_carern_avg_cost_per_visit > 0
    AND less_total_operating_expenses_sum_of_lines_4_through_16 > 0
  GROUP BY fiscal_year
)

SELECT
  fiscal_year,
  
  -- Cost metrics
  ROUND(avg_rn_cost_per_visit, 2) AS avg_rn_cost_per_visit,
  ROUND(avg_aide_cost_per_visit, 2) AS avg_aide_cost_per_visit,
  
  -- Service mix 
  ROUND(total_rn_visits * 100.0 / NULLIF(total_visits, 0), 1) AS rn_visit_pct,
  ROUND(total_aide_visits * 100.0 / NULLIF(total_visits, 0), 1) AS aide_visit_pct,
  
  -- Scale metrics
  ROUND(avg_operating_expense, 0) AS avg_operating_expense,
  provider_count,
  
  -- Operating metrics
  ROUND(total_visits / NULLIF(provider_count, 0), 0) AS avg_visits_per_provider

FROM yearly_metrics
ORDER BY fiscal_year DESC

-- HOW IT WORKS:
-- 1. Creates a CTE to calculate yearly metrics for cost, service mix and scale
-- 2. Filters to recent years and valid cost data
-- 3. Summarizes metrics at year level with appropriate grouping and averages
-- 4. Presents final results with formatted metrics and clear labels
-- 5. Uses NULLIF to prevent division by zero errors

-- ASSUMPTIONS & LIMITATIONS:
-- - Assumes cost and visit data is accurately reported
-- - Limited to agencies reporting valid cost per visit data
-- - Does not account for regional cost variations
-- - Service mix analysis limited to RN and aide visits as key indicators
-- - Excludes records with zero or missing operating expenses

-- POSSIBLE EXTENSIONS:
-- 1. Add geographic dimension to analyze regional patterns
-- 2. Include quality metrics to analyze cost/quality relationship
-- 3. Segment by agency size to identify economies of scale
-- 4. Add peer group comparisons by ownership type
-- 5. Compare urban vs rural cost structures
-- 6. Analyze impact of case mix on costs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:12:39.655976
    - Additional Notes: Query focuses on year-over-year operational efficiency metrics for home health agencies. Results are most meaningful for agencies with complete cost reporting data from 2015 onwards. The RN to aide visit ratio and cost trends provide insights into staffing models and resource allocation strategies. Operating expense trends should be interpreted considering inflation factors not included in this analysis.
    
    */