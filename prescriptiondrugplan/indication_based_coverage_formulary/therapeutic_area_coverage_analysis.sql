-- Therapeutic Area Coverage Strategy Analysis
--
-- Business Purpose:
-- Analyzes Medicare Part D plans' drug coverage strategies across major therapeutic areas
-- to identify specialization patterns and competitive differentiators.
-- This helps:
-- - Understand market positioning of different plans
-- - Identify potential gaps in therapeutic coverage
-- - Support formulary strategy decisions

WITH disease_categories AS (
  -- Group diseases into broader therapeutic categories and count drugs per category
  SELECT 
    contract_id,
    plan_id,
    -- Simplified categorization based on disease text patterns
    CASE 
      WHEN LOWER(disease) LIKE '%diabetes%' THEN 'Diabetes'
      WHEN LOWER(disease) LIKE '%cancer%' OR LOWER(disease) LIKE '%oncology%' THEN 'Oncology'
      WHEN LOWER(disease) LIKE '%heart%' OR LOWER(disease) LIKE '%cardio%' THEN 'Cardiovascular'
      WHEN LOWER(disease) LIKE '%arthritis%' OR LOWER(disease) LIKE '%inflammatory%' THEN 'Inflammatory'
      ELSE 'Other'
    END as therapeutic_area,
    COUNT(DISTINCT rxcui) as drug_count
  FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary)
  GROUP BY 1,2,3
)

SELECT 
  contract_id,
  plan_id,
  therapeutic_area,
  drug_count,
  -- Calculate percentage of total drugs for each therapeutic area within plan
  ROUND(drug_count * 100.0 / SUM(drug_count) OVER (PARTITION BY contract_id, plan_id), 2) as pct_of_plan_total,
  -- Compare to average coverage in therapeutic area across all plans
  ROUND(drug_count * 100.0 / AVG(drug_count) OVER (PARTITION BY therapeutic_area), 2) as pct_vs_category_avg
FROM disease_categories
ORDER BY contract_id, plan_id, drug_count DESC;

-- How the Query Works:
-- 1. Creates disease categories using pattern matching on disease descriptions
-- 2. Counts distinct drugs (RXCUIs) for each plan-category combination
-- 3. Calculates relative coverage metrics:
--    - Percentage of plan's total covered drugs
--    - Coverage relative to category average across all plans
-- 4. Uses most recent data snapshot via mimi_src_file_date filter

-- Assumptions & Limitations:
-- - Simple text-based disease categorization may miss some nuances
-- - Analysis based on drug counts, not considering utilization or cost
-- - Focuses on current snapshot only
-- - Does not account for plan size or market share

-- Possible Extensions:
-- 1. Add temporal analysis to track coverage changes
-- 2. Include plan attributes (MA-PD vs PDP, region, etc.)
-- 3. Incorporate drug costs or tier information
-- 4. Develop more sophisticated disease categorization
-- 5. Add market share or enrollment weighting

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:15:42.540349
    - Additional Notes: Query requires careful consideration of disease classification patterns in the CASE statement. The current categorization is simplified and may need adjustment based on actual disease descriptions in the data. Performance may be impacted with large datasets due to window functions. Consider indexing on mimi_src_file_date if frequent execution is needed.
    
    */