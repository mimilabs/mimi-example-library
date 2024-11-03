-- Title: Prescription Drug Plan Service Area and Coverage Analysis

-- Business Purpose:
-- - Map prescription drug plan coverage and service areas across contract types
-- - Identify market presence and distribution of plan offerings
-- - Support network adequacy and market expansion analysis
-- - Enable strategic planning for new plan offerings

-- Main Query
WITH contract_type_summary AS (
  SELECT 
    LEFT(contract_id, 1) as contract_type,
    CASE 
      WHEN LEFT(contract_id, 1) = 'H' THEN 'Local MA Plan'
      WHEN LEFT(contract_id, 1) = 'R' THEN 'Regional MA Plan'
      WHEN LEFT(contract_id, 1) = 'S' THEN 'Standalone PDP'
      ELSE 'Other'
    END as contract_type_desc,
    COUNT(DISTINCT contract_id) as num_contracts,
    COUNT(DISTINCT CONCAT(contract_id, plan_id)) as num_plans,
    COUNT(DISTINCT formulary_id) as num_unique_formularies,
    AVG(premium) as avg_premium,
    AVG(deductible) as avg_deductible
  FROM mimi_ws_1.prescriptiondrugplan.plan_information
  WHERE plan_suppressed_yn = 'N'
  GROUP BY 1, 2
)

SELECT 
  contract_type,
  contract_type_desc,
  num_contracts,
  num_plans,
  num_unique_formularies,
  ROUND(avg_premium, 2) as avg_premium,
  ROUND(avg_deductible, 2) as avg_deductible,
  ROUND(num_plans::FLOAT / num_contracts, 1) as avg_plans_per_contract,
  ROUND(num_plans::FLOAT / NULLIF(num_unique_formularies, 0), 1) as avg_plans_per_formulary
FROM contract_type_summary
ORDER BY num_plans DESC;

-- How the Query Works:
-- 1. Creates a CTE to summarize key metrics by contract type
-- 2. Uses LEFT() function to extract contract type indicator
-- 3. Calculates counts of unique contracts, plans, and formularies
-- 4. Computes average premium and deductible amounts
-- 5. Derives ratios for plans per contract and plans per formulary
-- 6. Filters out suppressed plans to ensure data quality

-- Assumptions and Limitations:
-- - Assumes contract_id first letter reliably indicates plan type
-- - Limited to active, non-suppressed plans
-- - Premium and deductible averages don't account for enrollment weights
-- - Geographic distribution not considered in this base analysis

-- Possible Extensions:
-- 1. Add temporal analysis by including mimi_src_file_date
-- 2. Include geographic distribution using state/region codes
-- 3. Add formulary coverage metrics by joining with formulary tables
-- 4. Incorporate SNP analysis for specialized market segments
-- 5. Add market concentration metrics (HHI) by region
-- 6. Compare premium/deductible trends across service areas
-- 7. Analyze correlation between number of plans and cost metrics
-- 8. Include pharmacy network breadth analysis
-- 9. Add benefit design comparisons across contract types
-- 10. Incorporate year-over-year change analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:57:47.574210
    - Additional Notes: This query provides strategic market overview metrics by analyzing plan distributions and costs across different contract types (Local MA, Regional MA, Standalone PDP). Consider adding WHERE clause for specific time periods when analyzing historical trends, as the base query includes all available data points.
    
    */