-- RBCS Family/Sub-Category Alignment Analysis
--
-- Business Purpose: Analyzes how medical procedure families are distributed across 
-- different subcategories to identify potential service line optimization opportunities
-- and gaps in care delivery models. This helps healthcare organizations and payers:
-- 1. Identify service line optimization opportunities
-- 2. Discover cross-specialty procedure patterns
-- 3. Support strategic planning for new programs or expansions

WITH active_procedures AS (
    SELECT 
        rbcs_cat_subcat,
        rbcs_subcat_desc,
        rbcs_famnumb,
        rbcs_family_desc,
        COUNT(DISTINCT hcpcs_cd) as procedure_count
    FROM mimi_ws_1.datacmsgov.betos
    WHERE hcpcs_cd_end_dt IS NULL 
        OR hcpcs_cd_end_dt > CURRENT_DATE()
    GROUP BY 
        rbcs_cat_subcat,
        rbcs_subcat_desc,
        rbcs_famnumb,
        rbcs_family_desc
),

large_families AS (
    SELECT 
        rbcs_cat_subcat,
        CONCAT_WS(', ',
            COLLECT_LIST(
                CASE 
                    WHEN procedure_count > 10 
                    THEN rbcs_family_desc 
                END
            )
        ) as major_families
    FROM active_procedures
    GROUP BY rbcs_cat_subcat
)

SELECT 
    a.rbcs_cat_subcat,
    a.rbcs_subcat_desc,
    COUNT(DISTINCT a.rbcs_famnumb) as unique_families,
    SUM(a.procedure_count) as total_procedures,
    ROUND(AVG(a.procedure_count), 1) as avg_procedures_per_family,
    MAX(a.procedure_count) as max_procedures_in_family,
    l.major_families
FROM active_procedures a
LEFT JOIN large_families l ON a.rbcs_cat_subcat = l.rbcs_cat_subcat
GROUP BY 
    a.rbcs_cat_subcat,
    a.rbcs_subcat_desc,
    l.major_families
HAVING unique_families > 1
ORDER BY total_procedures DESC;

-- How this works:
-- 1. Creates temp table of currently active procedures
-- 2. Creates separate CTE for aggregating family names using Spark SQL compatible functions
-- 3. Aggregates at subcategory level to show procedure family distribution
-- 4. Identifies subcategories with multiple procedure families
-- 5. Shows concentration metrics and major procedure families
--
-- Assumptions & Limitations:
-- - Focuses only on currently active procedures
-- - Does not account for procedure volumes/utilization
-- - May include some procedures that are rarely performed
--
-- Possible Extensions:
-- 1. Add trend analysis showing how family distributions change over time
-- 2. Include procedure complexity indicators 
-- 3. Cross-reference with specialty or site-of-service data
-- 4. Add revenue or cost implications where available
-- 5. Compare family distributions across different healthcare markets

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:33:07.707944
    - Additional Notes: This query focuses on currently active medical procedures and their distribution patterns across RBCS subcategories. The results highlight subcategories with diverse procedure families, which can be particularly useful for healthcare service line planning and resource allocation. The COLLECT_LIST function used requires Spark SQL 2.4+ for proper execution.
    
    */