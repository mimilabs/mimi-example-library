-- MEPS Office Visit Analysis - Service Gaps and Provider Specialties
-- Business Purpose: This analysis helps healthcare organizations and policymakers:
-- 1. Identify underserved specialties and service gaps
-- 2. Understand provider mix and specialty distribution
-- 3. Track telemedicine adoption patterns
-- 4. Support strategic planning for service expansion

WITH provider_specialty_summary AS (
    -- Aggregate provider and service details by year
    SELECT 
        obdateyr as visit_year,
        drsplty as provider_specialty,
        telehealthflag,
        COUNT(*) as visit_count,
        -- Calculate key service indicators
        SUM(CASE WHEN labtest = 1 THEN 1 ELSE 0 END) as lab_orders,
        SUM(CASE WHEN medpresc = 1 THEN 1 ELSE 0 END) as prescription_orders,
        SUM(CASE WHEN rcvvac = 1 THEN 1 ELSE 0 END) as vaccination_visits
    FROM mimi_ws_1.ahrq.meps_event_officevisits
    WHERE obdateyr IS NOT NULL 
    AND drsplty IS NOT NULL
    GROUP BY obdateyr, drsplty, telehealthflag
)

SELECT 
    visit_year,
    provider_specialty,
    visit_count,
    -- Calculate service ratios
    ROUND(lab_orders * 100.0 / visit_count, 2) as lab_order_rate,
    ROUND(prescription_orders * 100.0 / visit_count, 2) as prescription_rate,
    ROUND(vaccination_visits * 100.0 / visit_count, 2) as vaccination_rate,
    -- Telehealth adoption
    SUM(CASE WHEN telehealthflag = 1 THEN visit_count ELSE 0 END) as telehealth_visits,
    ROUND(SUM(CASE WHEN telehealthflag = 1 THEN visit_count ELSE 0 END) * 100.0 / visit_count, 2) as telehealth_rate
FROM provider_specialty_summary
GROUP BY 
    visit_year,
    provider_specialty,
    visit_count,
    lab_orders,
    prescription_orders,
    vaccination_visits
ORDER BY 
    visit_year DESC,
    visit_count DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate visit-level data by year and specialty
-- 2. Calculates service utilization rates for key indicators
-- 3. Adds telehealth adoption metrics
-- 4. Presents results ordered by year and visit volume

-- Assumptions and limitations:
-- 1. Relies on accurate coding of provider specialties
-- 2. Telehealth flag may not be consistently recorded across all years
-- 3. Some specialties may have small sample sizes
-- 4. Service patterns may vary by region (not included in this analysis)

-- Possible extensions:
-- 1. Add geographic analysis by combining with other MEPS tables
-- 2. Include cost analysis by specialty
-- 3. Compare service patterns between telehealth and in-person visits
-- 4. Add trend analysis across multiple years
-- 5. Include patient demographics to identify access disparities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:30:50.942114
    - Additional Notes: Query focuses on identifying service gaps and provider specialty distribution patterns across years. Note that the telehealth analysis is only meaningful for years 2020 and later due to COVID-19 impact on data collection methods.
    
    */