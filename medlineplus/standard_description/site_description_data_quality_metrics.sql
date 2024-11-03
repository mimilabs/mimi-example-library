-- Site Description Dataset Integrity Validation
-- Business Purpose:
-- - Assess data consistency and completeness for MedlinePlus site descriptions
-- - Identify potential data quality issues across source files
-- - Support data governance and maintenance decisions
-- - Enable longitudinal analysis of site description changes

WITH description_metrics AS (
    -- Calculate key metrics for each source file
    SELECT 
        mimi_src_file_name,
        mimi_src_file_date,
        COUNT(DISTINCT site_id) as unique_sites,
        COUNT(*) as total_records,
        COUNT(DISTINCT description) as unique_descriptions,
        MIN(mimi_src_file_date) as earliest_date,
        MAX(mimi_src_file_date) as latest_date,
        COUNT(CASE WHEN description IS NULL OR TRIM(description) = '' THEN 1 END) as missing_descriptions
    FROM mimi_ws_1.medlineplus.standard_description
    GROUP BY mimi_src_file_name, mimi_src_file_date
),
duplicate_check AS (
    -- Identify potential duplicate site descriptions
    SELECT 
        site_id,
        COUNT(*) as version_count,
        COUNT(DISTINCT description) as distinct_versions
    FROM mimi_ws_1.medlineplus.standard_description
    GROUP BY site_id
    HAVING COUNT(*) > 1
)

SELECT 
    dm.mimi_src_file_name,
    dm.unique_sites,
    dm.total_records,
    dm.unique_descriptions,
    dm.missing_descriptions,
    DATEDIFF(DAY, dm.earliest_date, dm.latest_date) as date_range_days,
    (SELECT COUNT(*) FROM duplicate_check) as sites_with_multiple_versions,
    ROUND((dm.missing_descriptions * 100.0 / dm.total_records), 2) as missing_description_pct
FROM description_metrics dm
ORDER BY dm.mimi_src_file_date DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate metrics by source file and date
-- 2. Creates a CTE to identify sites with multiple versions
-- 3. Combines results to show comprehensive data quality metrics
-- 4. Calculates percentages and date ranges for trending analysis

-- Assumptions and Limitations:
-- - Assumes site_id is the primary identifier for sites
-- - Assumes mimi_src_file_date reflects actual data currency
-- - Does not validate description content quality
-- - Does not check for semantic duplicates in descriptions

-- Possible Extensions:
-- 1. Add description length analysis
-- 2. Include change detection between versions
-- 3. Add classification of descriptions using keywords
-- 4. Compare against reference terminology standards
-- 5. Add time-based version control analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:53:42.858710
    - Additional Notes: Query provides data quality metrics including completeness, duplication rates, and temporal coverage of site descriptions. Note that DATEDIFF function assumes dates are in a format compatible with Databricks SQL. Source file dates are used as primary temporal indicators for trend analysis.
    
    */