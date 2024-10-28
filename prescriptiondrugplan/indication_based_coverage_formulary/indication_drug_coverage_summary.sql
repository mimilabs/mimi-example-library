
/*******************************************************************************
Title: Indication-Based Drug Coverage Analysis Across Medicare Part D Plans

Business Purpose:
This query analyzes the coverage landscape of prescription drugs across Medicare 
Part D plans based on FDA-approved indications. It helps identify:
- Most commonly covered diseases/indications
- Plans with broad vs narrow indication coverage
- Distribution of covered drugs per disease indication

The insights support:
- Plan comparison and evaluation
- Drug coverage pattern analysis
- Healthcare policy and access assessment
*******************************************************************************/

WITH disease_plan_counts AS (
  -- Calculate number of covered drugs per disease per plan
  SELECT 
    contract_id,
    plan_id,
    disease,
    COUNT(DISTINCT rxcui) as drugs_covered,
    mimi_src_file_date
  FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary
  GROUP BY contract_id, plan_id, disease, mimi_src_file_date
),

disease_summary AS (
  -- Get summary stats for each disease indication
  SELECT
    disease,
    COUNT(DISTINCT CONCAT(contract_id, plan_id)) as num_plans,
    AVG(drugs_covered) as avg_drugs_per_plan,
    MIN(drugs_covered) as min_drugs,
    MAX(drugs_covered) as max_drugs
  FROM disease_plan_counts
  GROUP BY disease
)

-- Final output showing diseases with coverage details
SELECT
  disease,
  num_plans,
  ROUND(avg_drugs_per_plan, 2) as avg_drugs_per_plan,
  min_drugs,
  max_drugs
FROM disease_summary
WHERE num_plans >= 10  -- Focus on commonly covered diseases
ORDER BY num_plans DESC, avg_drugs_per_plan DESC
LIMIT 20;

/*******************************************************************************
How the Query Works:
1. First CTE aggregates drug counts per disease for each plan
2. Second CTE calculates summary statistics across all plans per disease
3. Final query filters and formats results for the most relevant diseases

Assumptions & Limitations:
- Assumes current/valid plan and drug identifiers
- Limited to active coverage records
- Does not account for temporal changes in coverage
- Does not consider drug costs or restrictions

Possible Extensions:
1. Add temporal analysis by incorporating mimi_src_file_date trends
2. Join with plan_information to analyze by plan characteristics
3. Compare coverage patterns between MA-PD vs PDP plans
4. Analyze geographic variations in disease coverage
5. Include drug classification analysis using rxcui linkages
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:50:29.275236
    - Additional Notes: Query focuses on plans with at least 10 disease indications to ensure statistical relevance. Results are limited to top 20 diseases by plan coverage. Consider adjusting these thresholds based on specific analysis needs. The mimi_src_file_date field could be used to filter for specific time periods if needed.
    
    */