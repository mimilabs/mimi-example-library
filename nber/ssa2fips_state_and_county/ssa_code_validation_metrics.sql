-- Title: SSA Code Validation and Data Quality Assessment

-- Business Purpose:
-- This query helps data quality teams validate and audit SSA codes by:
-- - Identifying potential data quality issues in SSA code assignments
-- - Comparing SSA codes across geographic hierarchies
-- - Supporting data governance and standardization initiatives

SELECT 
    state_name,
    COUNT(DISTINCT ssa_code) as unique_ssa_codes,
    COUNT(DISTINCT fipscounty) as unique_fips_counties,
    -- Calculate ratio to identify potential mismatches
    ROUND(COUNT(DISTINCT ssa_code)::FLOAT / COUNT(DISTINCT fipscounty)::FLOAT, 2) as code_ratio,
    -- Flag states with potential data quality issues
    CASE 
        WHEN COUNT(DISTINCT ssa_code) <> COUNT(DISTINCT fipscounty) THEN 'Review Required'
        ELSE 'Matched'
    END as validation_status
FROM mimi_ws_1.nber.ssa2fips_state_and_county
GROUP BY state_name
-- Focus on states with potential mismatches
HAVING COUNT(DISTINCT ssa_code) <> COUNT(DISTINCT fipscounty)
ORDER BY code_ratio DESC;

-- How it works:
-- 1. Groups data by state to analyze code distributions
-- 2. Counts unique SSA and FIPS codes per state
-- 3. Calculates ratio between code types to identify mismatches
-- 4. Flags states requiring review based on code count differences

-- Assumptions and Limitations:
-- - Assumes 1:1 relationship between SSA and FIPS codes is expected
-- - Does not account for historical changes in county definitions
-- - Limited to current active codes only

-- Possible Extensions:
-- 1. Add temporal analysis to track code changes over time
-- 2. Include CBSA-level validation checks
-- 3. Incorporate reference data from other authoritative sources
-- 4. Add specific validation rules for known special cases
-- 5. Generate detailed mismatch reports with specific code pairs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:30:04.063459
    - Additional Notes: Query provides aggregate metrics for data quality validation between SSA and FIPS codes. Best used as part of regular data governance checks or when integrating new geographic data sources. May need adjustment for territories or special administrative regions not following standard coding patterns.
    
    */