-- COVID-19 Nursing Home Risk Assessment Dashboard
-- Business Purpose: Identify nursing homes with concerning COVID-19 trends to prioritize interventions
-- This query provides key metrics for risk assessment and resource allocation decisions
-- Created by: AI Assistant
-- Last Modified: 2024-02-12

WITH recent_data AS (
    -- Get the most recent reporting week's data
    SELECT MAX(week_ending) as latest_week
    FROM mimi_ws_1.datacmsgov.covid19nursinghomes
    WHERE passed_quality_assurance_check = 'Y'
),

facility_metrics AS (
    -- Calculate key risk metrics per facility
    SELECT 
        provider_name,
        provider_state,
        provider_city,
        number_of_all_beds,
        total_number_of_occupied_beds,
        weekly_resident_confirmed_covid19_cases_per_1000_residents as current_case_rate,
        recent_percentage_of_current_residents_up_to_date_with_covid19_vaccines as resident_vax_rate,
        recent_percentage_of_current_healthcare_personnel_up_to_date_with_covid19_vaccines as staff_vax_rate,
        residents_weekly_covid19_deaths as weekly_deaths
    FROM mimi_ws_1.datacmsgov.covid19nursinghomes nh
    INNER JOIN recent_data rd ON nh.week_ending = rd.latest_week
    WHERE passed_quality_assurance_check = 'Y'
)

SELECT 
    provider_state,
    provider_city,
    provider_name,
    number_of_all_beds,
    total_number_of_occupied_beds,
    current_case_rate,
    resident_vax_rate,
    staff_vax_rate,
    weekly_deaths,
    -- Flag high-risk facilities based on key metrics
    CASE 
        WHEN current_case_rate > 100 
             OR weekly_deaths > 0 
             OR resident_vax_rate < 50 
             OR staff_vax_rate < 50 
        THEN 'HIGH RISK'
        ELSE 'STANDARD MONITORING'
    END as risk_level
FROM facility_metrics
WHERE total_number_of_occupied_beds > 0
ORDER BY 
    CASE WHEN current_case_rate > 100 THEN 1 
         WHEN weekly_deaths > 0 THEN 2
         ELSE 3 END,
    current_case_rate DESC,
    weekly_deaths DESC;

-- How this query works:
-- 1. Identifies the most recent reporting week
-- 2. Pulls key metrics for each facility from that week
-- 3. Calculates a risk level based on cases, deaths, and vaccination rates
-- 4. Orders results to prioritize highest-risk facilities

-- Assumptions:
-- 1. Quality-assured data only (passed_quality_assurance_check = 'Y')
-- 2. Focuses on facilities with current occupancy (total_number_of_occupied_beds > 0)
-- 3. Risk thresholds are illustrative and should be adjusted based on current conditions

-- Limitations:
-- 1. Point-in-time analysis only
-- 2. Does not account for historical trends
-- 3. Simple risk scoring may not capture all relevant factors
-- 4. May need adjustment for regional variations in COVID-19 prevalence

-- Possible Extensions:
-- 1. Add trend analysis comparing to previous weeks
-- 2. Include county-level COVID-19 rates for context
-- 3. Create risk scores weighted by facility size and population vulnerability
-- 4. Add geographical clustering analysis
-- 5. Include staffing levels and shortages in risk assessment
-- 6. Compare against state and national averages
-- 7. Add facility ownership type analysis/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:18:31.346005
    - Additional Notes: Query focuses on point-in-time risk assessment using the latest available data. Risk thresholds (100 cases per 1000 residents, 50% vaccination rates) are placeholder values that should be adjusted based on current public health guidelines and local conditions. The dashboard assumes weekly data submission compliance and may not reflect facilities with delayed reporting.
    
    */