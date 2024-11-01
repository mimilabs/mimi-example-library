-- RxNorm Prescribable Medications Analysis
-- This query analyzes currently prescribable medications in RxNorm to support:
-- - Formulary management and drug coverage decisions
-- - Clinical decision support system development
-- - Healthcare cost analysis and pharmacy benefit planning

WITH prescribable_meds AS (
    -- Focus on current prescribable medications (CVF=4096)
    -- and active/current entries (suppress='N')
    SELECT DISTINCT 
        rxcui,
        str as medication_name,
        tty as term_type,
        sab as source,
        code as medication_code
    FROM mimi_ws_1.nlm.rxnconso
    WHERE cvf = '4096' 
    AND suppress = 'N'
),

source_summary AS (
    -- Summarize medication counts by source vocabulary
    SELECT 
        source,
        COUNT(DISTINCT rxcui) as med_count,
        COUNT(DISTINCT medication_code) as code_count
    FROM prescribable_meds
    GROUP BY source
    HAVING COUNT(DISTINCT rxcui) > 100  -- Focus on major sources
),

term_types AS (
    -- Aggregate term types for each source
    SELECT 
        source,
        CONCAT_WS(', ', COLLECT_SET(term_type)) as term_types,
        COUNT(DISTINCT medication_name) as unique_names
    FROM prescribable_meds
    GROUP BY source
)

-- Final output combining medication details with source statistics
SELECT 
    s.source,
    s.med_count,
    s.code_count,
    t.term_types,
    t.unique_names
FROM source_summary s
JOIN term_types t ON s.source = t.source
ORDER BY s.med_count DESC
LIMIT 10;

-- How this query works:
-- 1. First CTE filters for currently prescribable and active medications
-- 2. Second CTE summarizes medication counts by source vocabulary
-- 3. Third CTE handles term type aggregation using COLLECT_SET and CONCAT_WS
-- 4. Final query joins these together to provide a comprehensive view of major medication sources
-- and their characteristics

-- Assumptions and Limitations:
-- - Focuses only on currently prescribable medications (CVF=4096)
-- - Excludes suppressed/obsolete entries
-- - Limited to sources with >100 distinct medications
-- - Shows only top 10 sources by medication count

-- Possible Extensions:
-- 1. Add trend analysis by incorporating mimi_src_file_date
-- 2. Include specific term types (tty) analysis for clinical forms
-- 3. Compare prescribable vs. non-prescribable medications
-- 4. Add cost analysis by joining with pricing data
-- 5. Analyze brand vs. generic distribution within sources

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:18:23.187733
    - Additional Notes: Query focuses on the major medication vocabulary sources in RxNorm's prescribable content, providing counts of medications, codes, and term types per source. Results are limited to sources with more than 100 distinct medications and show only the top 10 sources by medication count. The COLLECT_SET function requires Spark SQL 2.4 or later.
    
    */