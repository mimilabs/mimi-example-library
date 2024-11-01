-- Drug Coverage Dynamics Analysis
--
-- Business Purpose:
-- Analyzes the temporal evolution of drug coverage decisions by Medicare plans
-- to identify shifts in formulary strategies. This helps:
-- - Understand how plans adapt their coverage over time
-- - Track adoption patterns for specific therapeutic classes
-- - Support market access planning and formulary optimization
--
-- Table: mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary

WITH coverage_changes AS (
  -- Get the earliest and latest coverage dates for each drug-disease combo
  SELECT 
    contract_id,
    plan_id,
    disease,
    COUNT(DISTINCT rxcui) as drug_count,
    MIN(mimi_src_file_date) as first_coverage_date,
    MAX(mimi_src_file_date) as latest_coverage_date,
    COUNT(DISTINCT mimi_src_file_date) as coverage_snapshots
  FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary
  GROUP BY 
    contract_id,
    plan_id,
    disease
)

SELECT
  disease,
  COUNT(DISTINCT CONCAT(contract_id, plan_id)) as total_plans,
  ROUND(AVG(drug_count), 2) as avg_drugs_per_plan,
  COUNT(CASE WHEN latest_coverage_date > first_coverage_date THEN 1 END) as plans_with_coverage_changes,
  COUNT(CASE WHEN coverage_snapshots > 1 THEN 1 END) as plans_with_multiple_snapshots
FROM coverage_changes
GROUP BY disease
HAVING total_plans >= 5  -- Focus on diseases with meaningful plan coverage
ORDER BY total_plans DESC, avg_drugs_per_plan DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to aggregate coverage metrics per plan-disease combination
-- 2. Calculates key coverage statistics at the disease level
-- 3. Filters for diseases with sufficient plan coverage
-- 4. Orders results by prevalence and coverage breadth
--
-- Assumptions and Limitations:
-- - Assumes changes in mimi_src_file_date represent actual coverage changes
-- - Limited to top 20 diseases by plan coverage
-- - Does not account for plan enrollment numbers
-- - Does not distinguish between plan types
--
-- Possible Extensions:
-- 1. Add plan type analysis (MA-PD vs PDP)
-- 2. Include geographic region analysis
-- 3. Add trend analysis comparing year-over-year changes
-- 4. Incorporate drug class information
-- 5. Add cost sharing tier analysis
-- 6. Compare against national coverage benchmarks

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:32:24.659744
    - Additional Notes: Query identifies temporal patterns in drug coverage across Medicare plans, focusing on diseases with significant plan participation. The analysis tracks changes in coverage decisions over time and provides insights into formulary strategy evolution. Best used with at least 6 months of historical data to detect meaningful coverage patterns.
    
    */