-- Home Health Agency Specialty Service Analysis
--
-- Business Purpose:
-- Analyzes the specialization patterns of Medicare-enrolled home health agencies to:
-- 1. Identify most common provider specialties and service offerings
-- 2. Compare specialization differences between for-profit and non-profit agencies
-- 3. Help stakeholders understand market positioning opportunities
-- 4. Support strategic planning for new service line development

WITH specialty_counts AS (
    -- Calculate provider type distribution with profit status
    SELECT 
        provider_type_text,
        proprietary_nonprofit,
        COUNT(*) as agency_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as pct_of_total
    FROM mimi_ws_1.datacmsgov.pc_homehealth
    WHERE provider_type_text IS NOT NULL
    GROUP BY provider_type_text, proprietary_nonprofit
),

profit_status_summary AS (
    -- Compare for-profit vs non-profit distribution
    SELECT 
        proprietary_nonprofit,
        COUNT(DISTINCT npi) as unique_providers,
        COUNT(DISTINCT ccn) as unique_facilities
    FROM mimi_ws_1.datacmsgov.pc_homehealth
    WHERE proprietary_nonprofit IS NOT NULL
    GROUP BY proprietary_nonprofit
)

-- Combine specialty and profit status insights
SELECT 
    sc.provider_type_text,
    sc.proprietary_nonprofit,
    sc.agency_count,
    ROUND(sc.pct_of_total, 2) as percent_of_total,
    ps.unique_providers,
    ps.unique_facilities
FROM specialty_counts sc
JOIN profit_status_summary ps 
    ON sc.proprietary_nonprofit = ps.proprietary_nonprofit
ORDER BY sc.agency_count DESC, sc.proprietary_nonprofit;

-- How this query works:
-- 1. First CTE calculates the distribution of provider types and their profit status
-- 2. Second CTE summarizes unique provider and facility counts by profit status
-- 3. Main query joins these insights to provide a comprehensive view of specialization patterns

-- Assumptions and limitations:
-- 1. Assumes provider_type_text accurately reflects primary service offering
-- 2. Limited to currently enrolled providers only
-- 3. Does not account for agencies offering multiple specialties
-- 4. Profit status field must be populated ("P" or "N")

-- Possible extensions:
-- 1. Add geographic dimension to analyze regional specialization patterns
-- 2. Include temporal analysis to track changes in specialization over time
-- 3. Cross-reference with quality metrics to assess performance by specialty
-- 4. Add size metrics (e.g., patient volume) to understand scale of operations
-- 5. Analyze correlation between specialties and incorporation dates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:38:49.779728
    - Additional Notes: Query performs well for strategic planning but may need index on provider_type_text and proprietary_nonprofit columns for larger datasets. Consider adding WHERE clause filters if analyzing specific time periods or regions.
    
    */