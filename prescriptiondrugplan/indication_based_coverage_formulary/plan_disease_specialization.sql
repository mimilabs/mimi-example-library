-- Title: Disease Specialization Analysis for Medicare Part D Plans
-- 
-- Business Purpose:
-- Identifies plans that specialize in covering specific diseases based on their 
-- indication-based drug coverage patterns. This analysis helps:
-- - Insurers understand market positioning opportunities
-- - Healthcare providers guide patients to specialized plans
-- - Policymakers assess plan diversity and disease coverage
--

WITH plan_disease_counts AS (
  -- Calculate number of covered drugs per disease for each plan
  SELECT 
    contract_id,
    plan_id,
    disease,
    COUNT(DISTINCT rxcui) as drugs_covered,
    -- Get most recent data per contract/plan/disease
    MAX(mimi_src_file_date) as latest_date
  FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary
  GROUP BY contract_id, plan_id, disease
),

plan_total_drugs AS (
  -- Get total drugs covered by each plan across all diseases
  SELECT
    contract_id, 
    plan_id,
    SUM(drugs_covered) as total_drugs
  FROM plan_disease_counts
  GROUP BY contract_id, plan_id
)

SELECT 
  pdc.contract_id,
  pdc.plan_id,
  pdc.disease,
  pdc.drugs_covered,
  ptd.total_drugs,
  -- Calculate coverage concentration for the disease
  ROUND(100.0 * pdc.drugs_covered / ptd.total_drugs, 2) as disease_coverage_pct,
  pdc.latest_date
FROM plan_disease_counts pdc
JOIN plan_total_drugs ptd 
  ON pdc.contract_id = ptd.contract_id 
  AND pdc.plan_id = ptd.plan_id
WHERE pdc.drugs_covered >= 5 -- Focus on meaningful coverage levels
ORDER BY disease_coverage_pct DESC, drugs_covered DESC
LIMIT 100

/*
How this works:
1. First CTE calculates drug coverage counts per disease for each plan
2. Second CTE calculates total drug coverage for each plan
3. Main query joins these to calculate coverage concentration percentages
4. Results show which plans have strong focus on particular diseases

Assumptions and Limitations:
- Uses raw drug counts without considering drug importance/prevalence
- Assumes current coverage patterns from latest data snapshot
- Minimum threshold of 5 drugs may need adjustment based on use case
- Does not account for plan enrollment or market size

Possible Extensions:
1. Add plan enrollment data to weight by market impact
2. Compare disease specialization across different geographic regions
3. Track specialization changes over time using mimi_src_file_date
4. Include cost sharing information for specialized disease coverage
5. Group similar diseases to identify therapeutic area specialization
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:24:30.600168
    - Additional Notes: Query identifies Part D plans with concentrated drug coverage in specific disease areas. The 5-drug minimum threshold and 100-row limit may need adjustment based on specific analysis needs. Consider total plan size when interpreting percentages, as smaller plans may show higher concentration percentages due to lower denominators.
    
    */