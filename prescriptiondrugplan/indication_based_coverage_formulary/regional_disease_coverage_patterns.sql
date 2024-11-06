-- Title: Regional Disease Coverage Analysis for Medicare Part D Plans

-- Business Purpose: 
-- This analysis examines geographic patterns in indication-based drug coverage,
-- highlighting regional variations in disease-specific formulary decisions.
-- Key business applications:
-- - Identify underserved disease areas by region
-- - Support market expansion strategies for pharmaceutical companies
-- - Guide beneficiaries in plan selection based on regional coverage patterns

WITH regional_plans AS (
    -- Extract region information from contract_id
    -- First two characters typically indicate region
    SELECT DISTINCT
        LEFT(contract_id, 2) as region_code,
        contract_id,
        plan_id
    FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary
),

disease_coverage AS (
    -- Calculate coverage metrics by region and disease
    SELECT 
        rp.region_code,
        f.disease,
        COUNT(DISTINCT f.rxcui) as unique_drugs_covered,
        COUNT(DISTINCT CONCAT(f.contract_id, f.plan_id)) as plans_offering_coverage
    FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary f
    JOIN regional_plans rp
        ON f.contract_id = rp.contract_id 
        AND f.plan_id = rp.plan_id
    WHERE f.mimi_src_file_date = (
        SELECT MAX(mimi_src_file_date) 
        FROM mimi_ws_1.prescriptiondrugplan.indication_based_coverage_formulary
    )
    GROUP BY 1, 2
)

-- Final output showing regional disease coverage patterns
SELECT 
    region_code,
    disease,
    unique_drugs_covered,
    plans_offering_coverage,
    ROUND(unique_drugs_covered * 1.0 / plans_offering_coverage, 2) as avg_drugs_per_plan
FROM disease_coverage
ORDER BY 
    region_code,
    unique_drugs_covered DESC;

-- How it works:
-- 1. First CTE extracts region codes from contract IDs
-- 2. Second CTE calculates key coverage metrics by region and disease
-- 3. Final query combines metrics and calculates average drugs per plan
-- 4. Results are ordered by region and coverage breadth

-- Assumptions and Limitations:
-- - Contract IDs consistently encode geographic regions in first two characters
-- - Analysis uses most recent data snapshot only
-- - Does not account for population demographics or disease prevalence
-- - Regional boundaries may not perfectly align with healthcare markets

-- Possible Extensions:
-- 1. Add temporal trend analysis by including multiple mimi_src_file_dates
-- 2. Join with plan_information to include plan characteristics
-- 3. Incorporate drug cost information for cost-coverage analysis
-- 4. Add disease categorization for therapeutic area analysis
-- 5. Compare coverage patterns between MA-PD and PDP plans

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:18:38.271352
    - Additional Notes: This query assumes standard CMS regional encoding in contract IDs. For accurate regional analysis, verify that the contract_id prefix consistently represents geographic regions in your dataset. Consider adding a reference table for proper region mapping if needed.
    
    */