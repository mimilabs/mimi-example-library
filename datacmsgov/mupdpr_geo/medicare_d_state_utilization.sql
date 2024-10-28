
/* 
Title: Medicare Part D Geographic Prescription Analysis - Core Metrics

Business Purpose:
This query analyzes key metrics around Medicare Part D prescription drug utilization and costs
across different geographic regions for the most recent year of data (2022). It provides:
- Total prescription claims and costs by state
- Identification of high-cost states and drugs
- Opioid prescription patterns by region

This forms a foundation for understanding geographic variations in Medicare Part D drug usage
and spending patterns.
*/

WITH state_metrics AS (
  SELECT 
    prscrbr_geo_desc as state,
    SUM(tot_clms) as total_claims,
    SUM(tot_drug_cst) as total_cost,
    ROUND(SUM(tot_drug_cst)/SUM(tot_clms),2) as cost_per_claim,
    SUM(CASE WHEN opioid_drug_flag = 'Y' THEN tot_clms ELSE 0 END) as opioid_claims,
    COUNT(DISTINCT brnd_name) as unique_drugs
  FROM mimi_ws_1.datacmsgov.mupdpr_geo
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    AND prscrbr_geo_lvl = 'State'          -- State level only
  GROUP BY prscrbr_geo_desc
)

SELECT 
  state,
  total_claims,
  -- Format costs in millions
  ROUND(total_cost/1000000,2) as total_cost_millions,
  cost_per_claim,
  opioid_claims,
  -- Calculate opioid percentage 
  ROUND(100.0 * opioid_claims/total_claims,1) as opioid_pct,
  unique_drugs,
  -- Add rankings
  RANK() OVER (ORDER BY total_cost DESC) as cost_rank,
  RANK() OVER (ORDER BY opioid_claims/total_claims DESC) as opioid_rank
FROM state_metrics
WHERE state != 'National'  -- Exclude national totals
ORDER BY total_cost DESC;

/*
How it works:
1. CTE calculates key metrics per state: claims, costs, opioid usage
2. Main query formats output and adds rankings
3. Filters to most recent year and state-level data

Assumptions & Limitations:
- Uses 2022 data only - trends over time not shown
- State level only - does not show sub-state variations
- Cost calculations include all payer sources
- Opioid flags based on CMS definitions

Possible Extensions:
1. Add year-over-year comparisons
2. Break down by specific drug types/classes
3. Add geographic visualizations
4. Compare with demographic or health outcome data
5. Analyze low-income subsidy impact
6. Include drill-down to specific high-cost drugs
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:06:34.087776
    - Additional Notes: Query analyzes Medicare Part D prescription data at state level for 2022, focusing on total claims, costs, and opioid usage. Results are ranked by total cost and opioid prescription rates. Note that cost values are presented in millions of dollars and percentages are rounded to one decimal place. Query requires access to the mupdpr_geo table with 2022 data present.
    
    */