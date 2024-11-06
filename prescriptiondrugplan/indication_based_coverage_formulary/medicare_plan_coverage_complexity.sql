-- Title: Indication-Based Drug Coverage Complexity Index for Medicare Plans

/* Business Purpose:
 * Develop a complexity score that quantifies the sophistication of Medicare Part D plans'
 * drug coverage strategies based on indication-based formulary diversity.
 * 
 * Key Insights:
 * - Measure plan complexity in drug coverage strategy
 * - Identify plans with nuanced, precise drug coverage approaches
 * - Support competitive intelligence for healthcare strategy teams
 */

WITH indication_complexity AS (
    SELECT 
        contract_id,
        plan_id,
        COUNT(DISTINCT disease) AS unique_disease_indications,
        COUNT(DISTINCT rxcui) AS unique_drugs_covered,
        ROUND(COUNT(DISTINCT rxcui) * 1.0 / NULLIF(COUNT(DISTINCT disease), 0), 2) AS drugs_per_indication,
        MAX(mimi_src_file_date) AS latest_coverage_update
    FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary
    WHERE disease IS NOT NULL
    GROUP BY contract_id, plan_id
),
complexity_scoring AS (
    SELECT 
        contract_id,
        plan_id,
        unique_disease_indications,
        unique_drugs_covered,
        drugs_per_indication,
        latest_coverage_update,
        
        -- Complexity scoring algorithm
        NTILE(5) OVER (ORDER BY unique_disease_indications * drugs_per_indication) AS coverage_complexity_quintile
    FROM indication_complexity
)

SELECT 
    contract_id,
    plan_id,
    unique_disease_indications,
    unique_drugs_covered,
    drugs_per_indication,
    latest_coverage_update,
    coverage_complexity_quintile,
    
    CASE 
        WHEN coverage_complexity_quintile = 5 THEN 'High Complexity Strategy'
        WHEN coverage_complexity_quintile = 4 THEN 'Moderately High Complexity'
        WHEN coverage_complexity_quintile = 3 THEN 'Medium Complexity'
        WHEN coverage_complexity_quintile = 2 THEN 'Low Complexity'
        ELSE 'Minimal Complexity'
    END AS strategy_complexity_description
FROM complexity_scoring
ORDER BY coverage_complexity_quintile DESC, unique_drugs_covered DESC
LIMIT 500;

/* Query Mechanics:
 * 1. Aggregates indication-based coverage data per plan
 * 2. Calculates metrics like unique diseases, drugs, and coverage density
 * 3. Creates a complexity quintile ranking
 * 4. Generates a qualitative complexity description
 *
 * Assumptions:
 * - More unique diseases and drugs indicate more sophisticated coverage
 * - Equal weight given to disease diversity and drug coverage breadth
 * 
 * Potential Extensions:
 * - Incorporate cost-sharing data
 * - Add regional segmentation
 * - Trend analysis of complexity over time
 */

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:11:45.161606
    - Additional Notes: Calculates a complexity index for Medicare Part D plans based on indication-based drug coverage. Uses a quintile-based scoring method to rank plans by their coverage sophistication. Provides insights into plan strategy diversity and drug coverage approach.
    
    */