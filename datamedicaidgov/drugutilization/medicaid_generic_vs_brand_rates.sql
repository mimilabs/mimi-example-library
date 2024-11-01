-- medicaid_generic_substitution_impact.sql
-- Business Purpose: Analyze the impact of generic drug substitution on Medicaid spending
-- by comparing brand vs generic utilization patterns across states. This analysis helps
-- identify opportunities to optimize generic drug usage and reduce program costs while
-- maintaining quality of care.

WITH brand_generic_comparison AS (
  -- Get total reimbursement and prescription counts by state and utilization type
  SELECT 
    state,
    utilization_type,
    -- First character of product code typically indicates brand (0) vs generic (1-9)
    CASE WHEN LEFT(product_code, 1) = '0' THEN 'Brand' ELSE 'Generic' END AS drug_type,
    SUM(total_amount_reimbursed) as total_reimbursement,
    SUM(number_of_prescriptions) as total_prescriptions,
    -- Calculate cost per prescription
    SUM(total_amount_reimbursed) / NULLIF(SUM(number_of_prescriptions), 0) as cost_per_rx
  FROM mimi_ws_1.datamedicaidgov.drugutilization
  WHERE year = 2022  -- Focus on most recent complete year
    AND suppression_used = FALSE  -- Exclude suppressed data
  GROUP BY 1,2,3
)

SELECT 
  state,
  utilization_type,
  -- Calculate key metrics
  SUM(CASE WHEN drug_type = 'Generic' THEN total_prescriptions ELSE 0 END) * 100.0 / 
    NULLIF(SUM(total_prescriptions), 0) as generic_utilization_rate,
  SUM(CASE WHEN drug_type = 'Generic' THEN total_reimbursement ELSE 0 END) * 100.0 / 
    NULLIF(SUM(total_reimbursement), 0) as generic_spend_rate,
  AVG(CASE WHEN drug_type = 'Brand' THEN cost_per_rx END) as avg_brand_cost_per_rx,
  AVG(CASE WHEN drug_type = 'Generic' THEN cost_per_rx END) as avg_generic_cost_per_rx
FROM brand_generic_comparison
GROUP BY 1,2
HAVING SUM(total_prescriptions) > 1000  -- Filter for states with significant volume
ORDER BY generic_utilization_rate DESC;

-- How this query works:
-- 1. Creates a CTE that classifies drugs as brand/generic based on product code
-- 2. Calculates total reimbursement and prescription counts by state and drug type
-- 3. Computes generic utilization rates and cost differentials
-- 4. Filters for meaningful data volumes and sorts by generic utilization

-- Assumptions and Limitations:
-- - Uses first digit of product code as brand/generic indicator (industry standard but not perfect)
-- - Focuses on 2022 data only
-- - Excludes suppressed data which may impact smaller states/programs
-- - Requires minimum prescription volume to ensure statistical relevance

-- Possible Extensions:
-- 1. Add trending over multiple years to show generic adoption patterns
-- 2. Include therapeutic class analysis to identify opportunities by drug category
-- 3. Compare MCO vs FFS generic utilization rates
-- 4. Calculate potential savings from increasing generic utilization to benchmark levels
-- 5. Add geographic clustering to identify regional patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:20:44.845138
    - Additional Notes: Query measures generic drug adoption rates and cost differentials across state Medicaid programs. Results are filtered for statistical significance (>1000 prescriptions) and exclude suppressed data. The brand/generic classification uses product code prefix, which may not capture all edge cases.
    
    */