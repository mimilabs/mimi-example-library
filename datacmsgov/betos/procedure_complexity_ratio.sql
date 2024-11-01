-- Procedure Complexity Distribution Analysis
--
-- Business Purpose:
-- Analyzes the distribution of procedure complexity (major vs other) across medical specialties
-- to help healthcare organizations optimize resource allocation and surgical capacity planning.
-- This insight is valuable for:
-- - Surgical center capacity planning
-- - Resource allocation and staffing
-- - Revenue cycle management
-- - Strategic service line development

WITH complexity_by_specialty AS (
    -- Group procedures by category and complexity indicator
    SELECT 
        rbcs_cat_desc AS specialty,
        rbcs_major_ind AS complexity_level,
        COUNT(*) AS procedure_count,
        -- Calculate percentage within each specialty
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY rbcs_cat_desc) AS percentage
    FROM mimi_ws_1.datacmsgov.betos
    WHERE 
        -- Focus on current procedures only
        (hcpcs_cd_end_dt IS NULL OR hcpcs_cd_end_dt > CURRENT_DATE)
        -- Exclude non-procedures
        AND rbcs_major_ind != 'N'
    GROUP BY 
        rbcs_cat_desc,
        rbcs_major_ind
)

SELECT 
    specialty,
    -- Format complexity distribution
    SUM(CASE WHEN complexity_level = 'M' THEN procedure_count ELSE 0 END) AS major_procedures,
    SUM(CASE WHEN complexity_level = 'O' THEN procedure_count ELSE 0 END) AS other_procedures,
    ROUND(SUM(CASE WHEN complexity_level = 'M' THEN percentage ELSE 0 END), 1) AS major_procedure_pct,
    ROUND(SUM(CASE WHEN complexity_level = 'O' THEN percentage ELSE 0 END), 1) AS other_procedure_pct
FROM complexity_by_specialty
GROUP BY specialty
ORDER BY major_procedure_pct DESC;

-- How this query works:
-- 1. Filters for active procedures only using end date check
-- 2. Excludes non-procedures (rbcs_major_ind = 'N')
-- 3. Groups procedures by specialty and complexity level
-- 4. Calculates distribution percentages within each specialty
-- 5. Presents results in an easy-to-understand format showing counts and percentages

-- Assumptions and Limitations:
-- - Assumes current procedures are those without end dates or future end dates
-- - Limited to binary complexity classification (major vs other)
-- - Does not account for procedure frequency in actual claims data
-- - Does not consider seasonal variations or geographic differences

-- Possible Extensions:
-- 1. Add trend analysis by comparing distributions across different _input_file_date values
-- 2. Include subcategory analysis for more granular insights
-- 3. Cross-reference with procedure families to identify complexity patterns
-- 4. Add filters for specific specialties or procedure types
-- 5. Include active/inactive ratio analysis for capacity planning

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:22:15.015662
    - Additional Notes: Query provides insight into the ratio of major vs. routine procedures across medical specialties, useful for surgical capacity planning and resource allocation. Note that complexity ratios are based on available procedure codes rather than actual procedure volumes, which may affect real-world application.
    
    */