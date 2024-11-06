-- Title: Clinical Procedure-to-Diagnosis Pathway Analysis
--
-- Business Purpose:
-- - Understand common clinical pathways by mapping procedures to their diagnostic reasons
-- - Identify frequently occurring procedure-diagnosis combinations
-- - Support clinical protocol development and standardization
-- - Enable better prediction of resource needs based on initial diagnoses

WITH procedure_reason_pairs AS (
    -- Select distinct procedure-reason combinations with frequencies
    SELECT 
        code AS procedure_code,
        description AS procedure_description,
        reasoncode AS diagnosis_code,
        reasondescription AS diagnosis_description,
        COUNT(*) as frequency,
        COUNT(DISTINCT patient) as unique_patients,
        AVG(base_cost) as avg_procedure_cost
    FROM mimi_ws_1.synthea.procedures
    WHERE reasoncode IS NOT NULL  -- Focus on procedures with documented reasons
    GROUP BY 
        procedure_code,
        procedure_description,
        diagnosis_code,
        diagnosis_description
)

SELECT 
    procedure_code,
    procedure_description,
    diagnosis_code,
    diagnosis_description,
    frequency,
    unique_patients,
    ROUND(avg_procedure_cost, 2) as avg_cost,
    ROUND(100.0 * frequency / SUM(frequency) OVER (), 2) as pct_of_total_procedures
FROM procedure_reason_pairs
WHERE frequency >= 10  -- Filter for meaningful patterns
ORDER BY frequency DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to aggregate procedure-diagnosis combinations
-- 2. Counts frequencies and unique patients for each combination
-- 3. Calculates average costs and percentage of total procedures
-- 4. Filters for combinations occurring at least 10 times
-- 5. Returns top 20 most common pathways

-- Assumptions and Limitations:
-- - Assumes reasoncode is populated for clinically relevant procedures
-- - Limited to top 20 combinations for initial analysis
-- - Does not account for temporal sequence of diagnoses and procedures
-- - Base_cost used without adjustments for different facilities/regions

-- Possible Extensions:
-- 1. Add time-to-procedure analysis (days between first diagnosis and procedure)
-- 2. Include patient demographic breakdowns
-- 3. Compare pathway variations across different facilities
-- 4. Add procedure success rate metrics if outcome data available
-- 5. Analyze multiple procedures per diagnosis patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:01:39.883495
    - Additional Notes: Query focuses on procedure-to-diagnosis relationships with minimum threshold of 10 occurrences. Results are limited to top 20 patterns. Requires reasoncode field to be populated for meaningful analysis. Cost calculations do not account for regional variations or facility-specific adjustments.
    
    */