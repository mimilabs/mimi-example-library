-- Title: Outpatient Care Service Mix Analysis
-- Business Purpose:
-- This query analyzes the diagnostic and treatment services provided during outpatient visits
-- to help healthcare organizations:
-- 1. Understand service utilization patterns
-- 2. Plan resource allocation and capacity
-- 3. Identify opportunities for service line expansion
-- 4. Support care quality and access initiatives

WITH service_summary AS (
    -- Calculate service utilization rates per visit
    SELECT 
        opdateyr as year,
        COUNT(*) as total_visits,
        SUM(CASE WHEN labtest = 1 THEN 1 ELSE 0 END) as lab_test_count,
        SUM(CASE WHEN sonogram = 1 THEN 1 ELSE 0 END) as sonogram_count,
        SUM(CASE WHEN xrays = 1 THEN 1 ELSE 0 END) as xray_count,
        SUM(CASE WHEN mammog = 1 THEN 1 ELSE 0 END) as mammogram_count,
        SUM(CASE WHEN mri = 1 THEN 1 ELSE 0 END) as mri_count,
        SUM(CASE WHEN ekg = 1 THEN 1 ELSE 0 END) as ekg_count,
        SUM(CASE WHEN rcvvac = 1 THEN 1 ELSE 0 END) as vaccination_count,
        SUM(CASE WHEN surgproc = 1 THEN 1 ELSE 0 END) as surgical_proc_count,
        SUM(CASE WHEN medpresc = 1 THEN 1 ELSE 0 END) as prescription_count
    FROM mimi_ws_1.ahrq.meps_event_outpatientvisits
    WHERE opdateyr IS NOT NULL
    GROUP BY opdateyr
)

SELECT 
    year,
    total_visits,
    -- Calculate service rates as percentage of total visits
    ROUND(100.0 * lab_test_count / total_visits, 1) as lab_test_rate,
    ROUND(100.0 * sonogram_count / total_visits, 1) as sonogram_rate,
    ROUND(100.0 * xray_count / total_visits, 1) as xray_rate,
    ROUND(100.0 * mammogram_count / total_visits, 1) as mammogram_rate,
    ROUND(100.0 * mri_count / total_visits, 1) as mri_rate,
    ROUND(100.0 * ekg_count / total_visits, 1) as ekg_rate,
    ROUND(100.0 * vaccination_count / total_visits, 1) as vaccination_rate,
    ROUND(100.0 * surgical_proc_count / total_visits, 1) as surgical_rate,
    ROUND(100.0 * prescription_count / total_visits, 1) as prescription_rate
FROM service_summary
ORDER BY year;

-- How the Query Works:
-- 1. Creates a CTE to aggregate service counts by year
-- 2. Calculates utilization rates as percentages in the main query
-- 3. Orders results chronologically to show trends

-- Assumptions and Limitations:
-- 1. Assumes binary flags (1/0) for service indicators
-- 2. Does not account for multiple services of same type in single visit
-- 3. Missing or null years are excluded
-- 4. Representative of US civilian non-institutionalized population only

-- Possible Extensions:
-- 1. Add geographic stratification (by region or urban/rural)
-- 2. Include provider specialty analysis
-- 3. Compare service mix by insurance type
-- 4. Add cost analysis by service type
-- 5. Incorporate telehealth vs in-person visit comparisons
-- 6. Add seasonal patterns analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:13:37.740748
    - Additional Notes: Query provides year-over-year trends in diagnostic and treatment service utilization rates. Results show percentage of visits including each service type, making it useful for service line planning and resource allocation. The analysis excludes visit complexity and combination of services which might be relevant for detailed capacity planning.
    
    */