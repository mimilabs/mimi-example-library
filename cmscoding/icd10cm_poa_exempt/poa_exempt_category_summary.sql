-- poa_exempt_coding_efficiency.sql
-- Purpose: Identify ICD-10-CM codes that are consistently exempt from POA reporting
-- to streamline medical coding workflows and reduce documentation burden
-- Business Value: Helps coding teams prioritize their review efforts and
-- supports training/automation initiatives for exempt conditions

WITH latest_exempt_codes AS (
    -- Get the most recent set of POA exempt codes
    SELECT DISTINCT 
        code,
        description,
        mimi_src_file_date
    FROM mimi_ws_1.cmscoding.icd10cm_poa_exempt
    WHERE mimi_src_file_date = (
        SELECT MAX(mimi_src_file_date) 
        FROM mimi_ws_1.cmscoding.icd10cm_poa_exempt
    )
),

code_patterns AS (
    -- Extract the high-level category from ICD-10 codes
    SELECT 
        SUBSTRING(code, 1, 1) as code_category,
        COUNT(*) as exempt_count,
        -- Modified STRING_AGG to use simpler syntax
        array_join(collect_list(description), '; ') as sample_conditions
    FROM latest_exempt_codes
    GROUP BY SUBSTRING(code, 1, 1)
)

SELECT 
    code_category,
    exempt_count,
    -- Limit sample conditions to prevent overwhelming output
    LEFT(sample_conditions, 100) as sample_conditions_truncated,
    ROUND(100.0 * exempt_count / SUM(exempt_count) OVER (), 1) as percent_of_total
FROM code_patterns
ORDER BY exempt_count DESC;

-- How this query works:
-- 1. Creates a CTE with the most recent POA exempt codes
-- 2. Groups codes by their first character to identify major clinical categories
-- 3. Calculates metrics and provides sample conditions for each category
-- 4. Orders results by frequency to highlight most impacted areas

-- Assumptions and Limitations:
-- - Assumes first character of ICD-10 code represents meaningful clinical grouping
-- - Limited to current POA exempt codes (doesn't track historical changes)
-- - Sample conditions are truncated for readability

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in exempt categories over time
-- 2. Cross-reference with claims data to quantify actual coding time savings
-- 3. Include mapping to clinical specialties for targeted process improvement
-- 4. Compare against full ICD-10 code set to calculate exemption rates by category
-- 5. Add drill-down capability for detailed code-level analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:31:06.657937
    - Additional Notes: Query focuses on high-level categorization of POA exempt codes to identify which medical condition categories have the most exemptions. The sample conditions are limited to first 100 characters for readability. The collect_list function used for description aggregation does not guarantee consistent ordering of conditions between runs.
    
    */