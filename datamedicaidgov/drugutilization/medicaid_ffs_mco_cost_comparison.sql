-- medicaid_service_type_financial_impact.sql
-- Business Purpose: Analyze financial differences between Fee-for-Service (FFS) and Managed Care (MCO) 
-- delivery models across states to inform payment model decisions and contracting strategies.
-- This analysis helps healthcare executives understand cost variations between delivery systems
-- and identify opportunities for payment reform.

WITH quarterly_service_metrics AS (
  -- Aggregate key metrics by state, year, quarter and service type
  SELECT 
    state,
    year,
    quarter,
    utilization_type,
    COUNT(DISTINCT ndc) as unique_drugs,
    SUM(number_of_prescriptions) as total_scripts,
    SUM(total_amount_reimbursed) as total_reimbursed,
    SUM(total_amount_reimbursed)/NULLIF(SUM(number_of_prescriptions),0) as cost_per_script
  FROM mimi_ws_1.datamedicaidgov.drugutilization
  WHERE suppression_used = false  -- Exclude suppressed data
  GROUP BY 1,2,3,4
),

state_service_comparison AS (
  -- Calculate metrics by state and service type for latest available period
  SELECT
    state,
    utilization_type,
    AVG(cost_per_script) as avg_cost_per_script,
    AVG(total_scripts) as avg_quarterly_scripts,
    AVG(total_reimbursed) as avg_quarterly_spend
  FROM quarterly_service_metrics
  WHERE year = (SELECT MAX(year) FROM quarterly_service_metrics) -- Latest year
  GROUP BY 1,2
)

-- Final output comparing FFS vs MCO metrics by state
SELECT 
  ffs.state,
  ffs.avg_cost_per_script as ffs_cost_per_script,
  mco.avg_cost_per_script as mco_cost_per_script,
  (ffs.avg_cost_per_script - mco.avg_cost_per_script) as cost_per_script_diff,
  ffs.avg_quarterly_spend as ffs_quarterly_spend,
  mco.avg_quarterly_spend as mco_quarterly_spend,
  (ffs.avg_quarterly_spend/NULLIF(mco.avg_quarterly_spend,0))*100 as ffs_to_mco_spend_ratio
FROM state_service_comparison ffs
LEFT JOIN state_service_comparison mco
  ON ffs.state = mco.state
  AND mco.utilization_type = 'MCOU'
WHERE ffs.utilization_type = 'FFSU'
ORDER BY ABS(cost_per_script_diff) DESC;

-- How it works:
-- 1. First CTE aggregates quarterly metrics by state and service type
-- 2. Second CTE calculates average metrics for latest year
-- 3. Final query joins FFS and MCO data to enable direct comparison
-- 4. Results show cost differences between delivery models by state

-- Assumptions and Limitations:
-- - Excludes suppressed data which may impact completeness
-- - Assumes consistent reporting across states
-- - Does not account for differences in patient populations
-- - Limited to prescription drug costs only

-- Possible Extensions:
-- 1. Add trending over time to show convergence/divergence
-- 2. Include drug mix analysis to explain cost differences
-- 3. Segment by specific drug categories or therapeutic classes
-- 4. Add population adjustment factors
-- 5. Include statistical significance testing of differences

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:40:11.196902
    - Additional Notes: Query focuses on cost differentials between Fee-for-Service and Managed Care delivery models. Note that results may be skewed for states that predominantly use one model over the other, or for states that recently transitioned between models. Zero values in MCO data may indicate capitated payment arrangements rather than missing data.
    
    */