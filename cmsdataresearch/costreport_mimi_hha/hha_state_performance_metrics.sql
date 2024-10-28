
/*************************************************************************
TITLE: Key Home Health Agency Metrics Analysis 

BUSINESS PURPOSE:
This query analyzes core performance metrics for home health agencies (HHAs)
to understand:
- Scale of operations (visit volumes, census)
- Financial health (revenues, costs, margins) 
- Quality of care delivery (types of services provided)
- Medicare/Medicaid program participation

The results provide essential insights for HHA performance benchmarking
and strategic planning.
*************************************************************************/

WITH agency_scale AS (
  -- Calculate key volume metrics per HHA
  SELECT 
    provider_ccn,
    hha_name,
    state_code,
    fiscal_year_end_date,
    total_medicare_title_xviii_visits as medicare_visits,
    total_medicaid_title_xix_visits as medicaid_visits,
    total_total_visits as all_visits,
    total_cost as total_cost,
    net_patient_revenues_line_1_minus_line_2_total as net_revenue,
    ROUND(net_patient_revenues_line_1_minus_line_2_total - total_cost, 2) as operating_margin
  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hha
  WHERE fiscal_year_end_date >= '2019-01-01'
    AND total_total_visits > 0  -- Exclude inactive agencies
)

SELECT
  state_code,
  COUNT(DISTINCT provider_ccn) as num_agencies,
  
  -- Volume metrics
  SUM(medicare_visits) as total_medicare_visits,
  SUM(medicaid_visits) as total_medicaid_visits,
  SUM(all_visits) as total_visits,
  
  -- Financial metrics 
  ROUND(AVG(total_cost), 2) as avg_cost_per_agency,
  ROUND(AVG(net_revenue), 2) as avg_revenue_per_agency,
  ROUND(AVG(operating_margin), 2) as avg_operating_margin,
  
  -- Efficiency metrics
  ROUND(AVG(net_revenue/NULLIF(all_visits,0)), 2) as avg_revenue_per_visit

FROM agency_scale
GROUP BY state_code
ORDER BY num_agencies DESC
LIMIT 10;

/*************************************************************************
HOW IT WORKS:
1. CTE filters for recent years and active agencies
2. Main query aggregates key metrics by state
3. Results show top 10 states by number of agencies

ASSUMPTIONS & LIMITATIONS:
- Focuses on agencies with visits > 0 to exclude inactive ones
- Uses fiscal year end date >= 2019 for recent view
- Revenue/cost metrics may need inflation adjustment for trend analysis
- State-level aggregation masks individual agency variation

POSSIBLE EXTENSIONS:
1. Add time trend analysis across fiscal years
2. Break out metrics by agency ownership type
3. Include quality metrics from other CMS datasets
4. Add geographic visualizations of metrics by state
5. Analyze impact of agency size on financial performance
*************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:37:14.819503
    - Additional Notes: Query focuses on core financial and operational metrics at the state level for recent years (2019+). Results are limited to states with active agencies and may not capture all nuances of individual agency performance. Consider adjusting fiscal year filter and adding trend analysis for more comprehensive insights.
    
    */