-- TITLE: FQHC Enrollment Trends and Medicare Integration Analysis

-- BUSINESS PURPOSE:
-- This analysis examines the Medicare enrollment patterns of FQHCs to understand:
-- - Timing and pace of FQHC integration into Medicare system
-- - Provider type composition in the FQHC landscape
-- - Organizational readiness through CCN assignments
-- Key stakeholders: Healthcare policy makers, Medicare administrators, FQHC operators

WITH latest_snapshot AS (
    -- Get most recent data snapshot
    SELECT MAX(mimi_src_file_date) as latest_date
    FROM mimi_ws_1.datacmsgov.pc_fqhc
),

enrollment_summary AS (
    -- Calculate key enrollment metrics
    SELECT 
        YEAR(incorporation_date) as incorporation_year,
        provider_type_text,
        COUNT(DISTINCT enrollment_id) as total_enrollments,
        COUNT(DISTINCT npi) as unique_npis,
        COUNT(DISTINCT ccn) as assigned_ccns,
        SUM(CASE WHEN ccn IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as ccn_assignment_rate
    FROM mimi_ws_1.datacmsgov.pc_fqhc f
    CROSS JOIN latest_snapshot ls
    WHERE f.mimi_src_file_date = ls.latest_date
    GROUP BY 
        YEAR(incorporation_date),
        provider_type_text
)

SELECT 
    incorporation_year,
    provider_type_text,
    total_enrollments,
    unique_npis,
    assigned_ccns,
    ROUND(ccn_assignment_rate, 2) as ccn_assignment_rate_pct
FROM enrollment_summary
WHERE incorporation_year IS NOT NULL
ORDER BY 
    incorporation_year DESC,
    total_enrollments DESC;

-- HOW IT WORKS:
-- 1. Identifies the most recent data snapshot to ensure temporal consistency
-- 2. Groups FQHCs by incorporation year and provider type
-- 3. Calculates key metrics including enrollment counts and CCN assignment rates
-- 4. Orders results chronologically to show enrollment evolution

-- ASSUMPTIONS AND LIMITATIONS:
-- - Assumes incorporation_date is a reliable indicator of FQHC program entry
-- - Limited to active Medicare-enrolled FQHCs
-- - Does not account for FQHCs that may have left the program
-- - CCN assignment patterns may vary by region or provider type

-- POSSIBLE EXTENSIONS:
-- 1. Add quarter-over-quarter enrollment growth rates
-- 2. Include geographic dimension to identify regional patterns
-- 3. Compare incorporation dates to actual Medicare enrollment dates
-- 4. Analyze correlation between CCN assignment rates and FQHC characteristics
-- 5. Track changes in provider type composition over time

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:45:00.935676
    - Additional Notes: The query provides core Medicare enrollment metrics but depends on complete and accurate incorporation_date values. For comprehensive trending, users may need to combine this with external data on historical FQHC certifications. The CCN assignment rate calculation assumes that all FQHCs should have CCNs, which may not reflect program requirements across different time periods.
    
    */