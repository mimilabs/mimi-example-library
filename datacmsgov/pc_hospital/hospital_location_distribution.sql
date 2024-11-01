-- Hospital Practice Location Type Analysis
-- 
-- Business Purpose:
-- - Understand how hospitals structure their physical locations and delivery settings
-- - Identify patterns in where and how healthcare services are being delivered
-- - Support facility planning and network adequacy assessments
-- - Guide market expansion strategies based on prevalent location models

WITH location_summary AS (
    -- Aggregate practice location types and count hospitals
    SELECT 
        practice_location_type,
        state,
        COUNT(DISTINCT enrollment_id) as hospital_count,
        COUNT(DISTINCT associate_id) as unique_organization_count,
        ROUND(AVG(CASE WHEN proprietary_nonprofit = 'P' THEN 100.0 ELSE 0 END),1) as pct_proprietary
    FROM mimi_ws_1.datacmsgov.pc_hospital
    WHERE practice_location_type IS NOT NULL
    GROUP BY practice_location_type, state
),

state_totals AS (
    -- Calculate state-level totals for percentage calculations
    SELECT 
        state,
        SUM(hospital_count) as total_hospitals_in_state
    FROM location_summary
    GROUP BY state
)

SELECT 
    l.state,
    l.practice_location_type,
    l.hospital_count,
    l.unique_organization_count,
    ROUND(100.0 * l.hospital_count / s.total_hospitals_in_state, 1) as pct_of_state_hospitals,
    l.pct_proprietary
FROM location_summary l
JOIN state_totals s ON l.state = s.state
WHERE s.total_hospitals_in_state >= 10  -- Focus on states with meaningful sample sizes
ORDER BY 
    l.state,
    l.hospital_count DESC;

-- How this query works:
-- 1. Creates summary of practice location types by state
-- 2. Calculates state totals for percentage calculations
-- 3. Joins the summaries to produce final analysis
-- 4. Filters for states with at least 10 hospitals for statistical relevance
-- 5. Orders results by state and hospital count for easy interpretation

-- Assumptions and Limitations:
-- - Practice location type field is accurately reported
-- - Analysis excludes states with fewer than 10 hospitals
-- - Does not account for temporal changes in facility status
-- - Treats all facility types equally regardless of size or capacity

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in location types over time
-- 2. Include facility size metrics (if available) for weighted analysis
-- 3. Cross-reference with specialty unit availability
-- 4. Add geographic clustering analysis using zip codes
-- 5. Compare location types against local population demographics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:07:34.208728
    - Additional Notes: Query focuses on physical location patterns of Medicare-enrolled hospitals and requires at least 10 hospitals per state for meaningful analysis. The practice_location_type field is crucial for results - data quality in this field should be verified before using for strategic decisions. Consider state-specific regulations that might influence location type distributions when interpreting results.
    
    */