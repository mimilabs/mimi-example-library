-- TITLE: Home Health Agency Cost Report Summary - Operational Model & Growth Trends

-- BUSINESS PURPOSE:
-- This analysis examines home health agencies' key operational metrics and growth patterns by:
-- - Identifying agencies with consistent growth in total visits and patient census
-- - Analyzing service mix and staffing model evolution
-- - Understanding operating costs and revenue trends
-- - Tracking Medicare vs non-Medicare business expansion
-- The insights support strategic planning and operational benchmarking.

WITH annual_metrics AS (
  -- Calculate key metrics by provider and year
  SELECT
    provider_ccn,
    hha_name,
    state_code,
    YEAR(fiscal_year_end_date) as fiscal_year,
    
    -- Scale metrics
    total_total_visits as total_visits,
    total_medicare_title_xviii_visits as medicare_visits,
    total_medicaid_title_xix_visits as medicaid_visits,
    
    -- Financial metrics
    total_cost as operating_cost,
    net_patient_revenues_line_1_minus_line_2_total as net_revenue,
    
    -- Service mix
    skilled_nursing_carern_total_visits as rn_visits,
    physical_therapy_total_visits as pt_visits,
    home_health_aide_total_visits as aide_visits,
    
    -- Operating model
    (skilled_nursing_carern_total_visits + skilled_nursing_carelpn_total_visits) * 1.0 / 
      NULLIF(total_total_visits, 0) as nursing_visit_ratio,
    
    (physical_therapy_total_visits + occupational_therapy_total_visits) * 1.0 / 
      NULLIF(total_total_visits, 0) as therapy_visit_ratio

  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hha
  WHERE fiscal_year_end_date IS NOT NULL
)

SELECT
  fiscal_year,
  COUNT(DISTINCT provider_ccn) as active_providers,
  
  -- Volume metrics
  AVG(total_visits) as avg_total_visits,
  AVG(medicare_visits * 1.0 / NULLIF(total_visits, 0)) as avg_medicare_ratio,
  
  -- Financial metrics  
  AVG(operating_cost * 1.0 / NULLIF(total_visits, 0)) as avg_cost_per_visit,
  AVG(net_revenue * 1.0 / NULLIF(operating_cost, 0)) as avg_revenue_cost_ratio,
  
  -- Service mix
  AVG(nursing_visit_ratio) as avg_nursing_ratio,
  AVG(therapy_visit_ratio) as avg_therapy_ratio

FROM annual_metrics
WHERE fiscal_year BETWEEN 2015 AND 2020
GROUP BY fiscal_year
ORDER BY fiscal_year;

-- HOW IT WORKS:
-- 1. Creates annual_metrics CTE to calculate key operational metrics by provider/year
-- 2. Aggregates metrics across providers for each fiscal year
-- 3. Focuses on core ratios showing business model evolution
-- 4. Provides trend analysis for strategic planning

-- ASSUMPTIONS & LIMITATIONS:
-- - Assumes fiscal year end date is populated and valid
-- - Limited to 2015-2020 for consistent comparison
-- - Does not account for organizational changes/M&A
-- - Ratios may be skewed by extreme outliers

-- POSSIBLE EXTENSIONS:
-- 1. Add provider size segments for more granular analysis
-- 2. Include geographic groupings to identify regional patterns
-- 3. Calculate year-over-year growth rates for key metrics
-- 4. Add quality metrics correlation analysis
-- 5. Include payer mix impact on operating metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:31:32.930197
    - Additional Notes: Query examines operational evolution of home health agencies over time, focusing on key growth metrics like visit volumes, service mix ratios, and financial performance. Best used for strategic analysis and benchmarking of operational models. Requires fiscal_year_end_date to be populated and valid in the source data.
    
    */