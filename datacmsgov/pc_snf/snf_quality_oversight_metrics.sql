-- Title: SNF Quality Assessment Readiness Analysis

-- Business Purpose:
-- This analysis helps identify SNFs that may require additional quality oversight
-- or support based on key operational characteristics by examining:
-- 1. The relationship between organizational structure and operational scope
-- 2. Basic risk factors that could impact care quality
-- 3. Facilities that may need enhanced monitoring or support

WITH facility_metrics AS (
    -- Calculate key operational metrics per facility
    SELECT 
        ccn,
        organization_name,
        state,
        proprietary_nonprofit,
        organization_type_structure,
        CASE 
            WHEN multiple_npi_flag = 'Y' THEN 1
            ELSE 0 
        END as has_multiple_npis,
        CASE
            WHEN incorporation_date IS NULL THEN 1
            ELSE 0
        END as missing_incorporation_date,
        CASE 
            WHEN doing_business_as_name != organization_name THEN 1
            ELSE 0
        END as has_dba_different
    FROM mimi_ws_1.datacmsgov.pc_snf
    WHERE ccn IS NOT NULL
)

SELECT 
    state,
    proprietary_nonprofit,
    organization_type_structure,
    COUNT(*) as facility_count,
    -- Calculate risk indicators
    SUM(has_multiple_npis) as multi_npi_count,
    SUM(missing_incorporation_date) as incomplete_records,
    SUM(has_dba_different) as name_discrepancy_count,
    -- Calculate percentages for comparison
    ROUND(100.0 * SUM(has_multiple_npis) / COUNT(*), 2) as pct_multi_npi,
    ROUND(100.0 * SUM(missing_incorporation_date) / COUNT(*), 2) as pct_incomplete,
    ROUND(100.0 * SUM(has_dba_different) / COUNT(*), 2) as pct_name_discrepancy
FROM facility_metrics
GROUP BY 
    state,
    proprietary_nonprofit,
    organization_type_structure
HAVING COUNT(*) >= 5  -- Focus on groups with meaningful sample sizes
ORDER BY 
    facility_count DESC,
    state;

-- How this query works:
-- 1. Creates a CTE to calculate facility-level metrics including:
--    - Multiple NPI flag status
--    - Missing incorporation date
--    - Discrepancy between legal and DBA names
-- 2. Aggregates these metrics by state and organizational characteristics
-- 3. Calculates both raw counts and percentages for comparison
-- 4. Filters for groups with at least 5 facilities for statistical relevance

-- Assumptions and Limitations:
-- 1. Assumes CCN is a reliable identifier for unique facilities
-- 2. Treats missing incorporation dates as a potential risk factor
-- 3. Assumes name discrepancies might indicate operational complexity
-- 4. Limited to current enrollment data; no historical trending
-- 5. Does not account for facility size or patient volume

-- Possible Extensions:
-- 1. Add facility age calculation based on incorporation_date
-- 2. Include geographic clustering analysis using zip_code
-- 3. Cross-reference with ownership data for corporate structure impact
-- 4. Add time-based analysis using mimi_src_file_date
-- 5. Incorporate additional risk factors based on organization_type_structure
-- 6. Compare metrics across different incorporation_states

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:16:36.421321
    - Additional Notes: The query requires a minimum of 5 facilities per group to generate results, which may exclude analysis of smaller states or uncommon organization types. The risk indicators (multiple NPIs, missing dates, name discrepancies) are proxy metrics and should be validated against actual quality outcomes before using for regulatory decisions.
    
    */