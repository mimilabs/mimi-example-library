-- Subcategory Major Procedure Volume Comparison
--
-- Business Purpose:
-- Analyzes the distribution of major procedures across subcategories
-- to help healthcare organizations identify high-complexity service areas
-- and optimize resource allocation for critical procedures.
-- This insight supports strategic planning, staffing, and facility utilization.

WITH major_procedures AS (
    -- Get counts of major procedures by subcategory 
    SELECT 
        rbcs_cat_subcat,
        rbcs_subcat_desc,
        COUNT(*) as procedure_count,
        SUM(CASE WHEN rbcs_major_ind = 'M' THEN 1 ELSE 0 END) as major_count,
        ROUND(SUM(CASE WHEN rbcs_major_ind = 'M' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as major_pct
    FROM mimi_ws_1.datacmsgov.betos
    WHERE hcpcs_cd_end_dt IS NULL  -- Only consider active procedures
    GROUP BY rbcs_cat_subcat, rbcs_subcat_desc
    HAVING COUNT(*) >= 10  -- Filter for subcategories with meaningful volume
)

SELECT 
    rbcs_cat_subcat,
    rbcs_subcat_desc,
    procedure_count as total_procedures,
    major_count as major_procedures,
    major_pct as major_procedure_percentage
FROM major_procedures
WHERE major_count > 0  -- Only show subcategories with major procedures
ORDER BY major_pct DESC, procedure_count DESC
LIMIT 15;  -- Focus on top subcategories

-- How the Query Works:
-- 1. Creates a CTE to aggregate procedure counts by subcategory
-- 2. Calculates total procedures and major procedure counts
-- 3. Computes percentage of major procedures
-- 4. Filters for active procedures and meaningful volumes
-- 5. Returns top subcategories ordered by major procedure percentage

-- Assumptions and Limitations:
-- - Assumes current active procedures (null end date) are most relevant
-- - Limited to subcategories with at least 10 procedures for statistical significance
-- - Does not account for procedure frequency in actual claims
-- - Major procedure indicator is taken as defined in the source data

-- Possible Extensions:
-- 1. Add trend analysis by comparing against historical data
-- 2. Include cost implications using Medicare fee schedule data
-- 3. Add geographical distribution of major procedures
-- 4. Compare against quality metrics or outcomes data
-- 5. Analyze seasonal patterns in major procedure volumes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:16:25.202781
    - Additional Notes: The query provides strategic insights focused on major procedure intensity across subcategories, particularly useful for capacity planning and resource allocation. Note that it only considers currently active procedures and requires a minimum volume threshold of 10 procedures per subcategory for meaningful analysis.
    
    */