-- RxNorm Drug Suppression Status Analysis Across Time
--
-- Business Purpose:
-- This analysis examines drug concept suppression patterns in RxNorm to support:
-- - Drug safety monitoring and compliance
-- - Formulary maintenance and updates
-- - Historical tracking of medication status changes
-- - Quality control for prescribing systems

WITH current_suppression AS (
    -- Get the most recent data for each drug concept
    SELECT 
        rxcui,
        str AS drug_name,
        suppress,
        cvf,
        sab AS source,
        mimi_src_file_date
    FROM mimi_ws_1.nlm.rxnconso
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.nlm.rxnconso)
),

suppression_summary AS (
    -- Summarize suppression status distribution
    SELECT 
        suppress,
        COUNT(DISTINCT rxcui) as concept_count,
        COUNT(DISTINCT CASE WHEN cvf = '4096' THEN rxcui END) as prescribable_count,
        ROUND(COUNT(DISTINCT rxcui) * 100.0 / SUM(COUNT(DISTINCT rxcui)) OVER(), 2) as percentage
    FROM current_suppression
    GROUP BY suppress
)

SELECT 
    CASE suppress
        WHEN 'N' THEN 'Active (Not Suppressed)'
        WHEN 'O' THEN 'Obsolete'
        WHEN 'Y' THEN 'Suppressed by Editor'
        WHEN 'E' THEN 'Non-prescribable with alternatives'
        ELSE 'Unknown'
    END AS suppression_status,
    concept_count,
    prescribable_count,
    percentage as percent_of_total,
    ROUND(prescribable_count * 100.0 / concept_count, 2) as percent_prescribable
FROM suppression_summary
ORDER BY concept_count DESC;

-- How this query works:
-- 1. First CTE gets the most recent snapshot of drug concepts
-- 2. Second CTE calculates key metrics about suppression status
-- 3. Final SELECT formats results with meaningful labels and calculations

-- Assumptions and Limitations:
-- - Assumes latest mimi_src_file_date represents current state
-- - Limited to analysis of suppression status only
-- - Does not track historical changes in suppression status
-- - Focuses on unique concepts rather than all occurrences

-- Possible Extensions:
-- 1. Add trend analysis across multiple mimi_src_file_dates
-- 2. Include source (sab) distribution within each suppression category
-- 3. Add specific drug examples for each suppression status
-- 4. Compare suppression patterns across different term types (tty)
-- 5. Create alerts for newly suppressed medications

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:09:11.833656
    - Additional Notes: The query focuses on the current state of drug suppressions across RxNorm and includes prescribability metrics. It helps identify the distribution of active, obsolete, and suppressed medications, which is valuable for maintaining drug formularies and ensuring prescription safety. The percentage calculations provide context for both overall distribution and prescribability within each suppression category.
    
    */