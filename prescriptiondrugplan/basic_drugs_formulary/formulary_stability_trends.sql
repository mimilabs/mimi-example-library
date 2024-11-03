-- Title: Medicare Part D Formulary Coverage Stability Analysis

-- Business Purpose:
-- This analysis tracks formulary changes over time to identify:
-- 1. Stability of drug coverage within formularies
-- 2. Patterns in formulary updates that may impact beneficiary access
-- 3. Year-over-year consistency in drug availability
-- This helps health plans and PBMs understand formulary management practices
-- and supports beneficiary communication planning around formulary changes.

WITH formulary_snapshots AS (
    -- Get distinct snapshots of formulary versions by date
    SELECT DISTINCT
        formulary_id,
        formulary_version,
        contract_year,
        mimi_src_file_date,
        COUNT(DISTINCT rxcui) as total_drugs
    FROM mimi_ws_1.prescriptiondrugplan.basic_drugs_formulary
    GROUP BY 1,2,3,4
),

formulary_changes AS (
    -- Compare consecutive snapshots to identify changes
    SELECT 
        f1.formulary_id,
        f1.contract_year,
        f1.mimi_src_file_date as current_date,
        f1.total_drugs as current_drugs,
        LAG(f1.total_drugs) OVER (
            PARTITION BY f1.formulary_id, f1.contract_year 
            ORDER BY f1.mimi_src_file_date
        ) as previous_drugs,
        f1.formulary_version as current_version,
        LAG(f1.formulary_version) OVER (
            PARTITION BY f1.formulary_id, f1.contract_year 
            ORDER BY f1.mimi_src_file_date
        ) as previous_version
    FROM formulary_snapshots f1
)

SELECT 
    formulary_id,
    contract_year,
    current_date,
    current_drugs,
    previous_drugs,
    COALESCE(current_drugs - previous_drugs, 0) as net_drug_change,
    CASE 
        WHEN previous_drugs IS NULL THEN 'Initial Version'
        WHEN current_drugs > previous_drugs THEN 'Expanded'
        WHEN current_drugs < previous_drugs THEN 'Reduced'
        ELSE 'No Change'
    END as change_type,
    current_version,
    previous_version
FROM formulary_changes
WHERE current_date IS NOT NULL
ORDER BY formulary_id, current_date;

-- How it works:
-- 1. First CTE creates snapshots of formularies at each point in time
-- 2. Second CTE compares consecutive versions of the same formulary
-- 3. Final SELECT summarizes the changes between versions

-- Assumptions and Limitations:
-- 1. Assumes formulary_version changes indicate meaningful updates
-- 2. Does not track specific drugs added/removed, only net changes
-- 3. May not capture minor changes that don't affect drug counts
-- 4. Requires multiple snapshots in time for meaningful analysis

-- Possible Extensions:
-- 1. Add specific drug class analysis to track therapeutic category changes
-- 2. Include tier level changes in stability analysis
-- 3. Add seasonality analysis of formulary changes
-- 4. Compare stability patterns across different types of plans
-- 5. Calculate average time between formulary updates
-- 6. Add correlation analysis with major drug launches or patent expirations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:45:44.835597
    - Additional Notes: This query requires multiple time snapshots in the source data to generate meaningful results. Consider adding date range filters if analyzing large historical datasets. The net_drug_change metric should be interpreted alongside the change_type column for proper context, as identical net changes could represent different underlying formulary modifications.
    
    */