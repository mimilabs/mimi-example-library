-- Medicare Beneficiary Technology Adoption and Telehealth Usage Analysis
--
-- Business Purpose:
-- Analyze the adoption of technology and telehealth services among Medicare beneficiaries
-- to understand digital engagement patterns and inform digital health strategy.
-- This analysis helps healthcare organizations:
-- 1. Plan digital health investments
-- 2. Design patient engagement strategies
-- 3. Identify opportunities to expand telehealth services
-- 4. Understand barriers to digital health adoption

WITH tech_adoption AS (
    SELECT 
        surveyyr,
        -- Technology access indicators
        COUNT(*) as total_beneficiaries,
        SUM(CASE WHEN knw_compdesk = '1' THEN 1 ELSE 0 END) as has_computer,
        SUM(CASE WHEN knw_compphon = '1' THEN 1 ELSE 0 END) as has_smartphone,
        SUM(CASE WHEN knw_comptab = '1' THEN 1 ELSE 0 END) as has_tablet,
        
        -- Digital health engagement
        SUM(CASE WHEN knw_kcominte = '1' THEN 1 ELSE 0 END) as uses_internet_health,
        SUM(CASE WHEN knw_kcomappo = '1' THEN 1 ELSE 0 END) as books_appointments_online,
        SUM(CASE WHEN knw_kcompres = '1' THEN 1 ELSE 0 END) as fills_prescriptions_online,
        
        -- Telehealth adoption
        SUM(CASE WHEN tmw_telmedus = '1' THEN 1 ELSE 0 END) as used_telehealth,
        SUM(CASE WHEN tmw_telmedt4 = '1' THEN 1 ELSE 0 END) as used_phone_visits,
        SUM(CASE WHEN tmw_telmedt4 = '2' THEN 1 ELSE 0 END) as used_video_visits
    FROM mimi_ws_1.datacmsgov.mcbs_winter
    WHERE surveyyr >= 2020  -- Focus on recent years with telehealth data
    GROUP BY surveyyr
)

SELECT
    surveyyr as year,
    total_beneficiaries,
    -- Calculate technology adoption rates
    ROUND(100.0 * has_computer / total_beneficiaries, 1) as computer_adoption_pct,
    ROUND(100.0 * has_smartphone / total_beneficiaries, 1) as smartphone_adoption_pct,
    ROUND(100.0 * has_tablet / total_beneficiaries, 1) as tablet_adoption_pct,
    
    -- Calculate digital health engagement rates
    ROUND(100.0 * uses_internet_health / total_beneficiaries, 1) as health_internet_usage_pct,
    ROUND(100.0 * books_appointments_online / total_beneficiaries, 1) as online_booking_pct,
    ROUND(100.0 * fills_prescriptions_online / total_beneficiaries, 1) as online_rx_pct,
    
    -- Calculate telehealth adoption rates
    ROUND(100.0 * used_telehealth / total_beneficiaries, 1) as telehealth_adoption_pct,
    ROUND(100.0 * used_phone_visits / used_telehealth, 1) as phone_visit_pct,
    ROUND(100.0 * used_video_visits / used_telehealth, 1) as video_visit_pct
FROM tech_adoption
ORDER BY surveyyr;

-- How this query works:
-- 1. Creates a CTE to aggregate technology and telehealth usage metrics by year
-- 2. Calculates adoption percentages in the main query
-- 3. Focuses on years 2020+ when telehealth data became available
-- 4. Uses consistent denominator (total_beneficiaries) for most metrics
-- 5. Calculates phone/video percentages based on telehealth users only

-- Assumptions and limitations:
-- 1. Missing or invalid responses are treated as "No"
-- 2. Data quality may vary across years as questions evolved
-- 3. Survey responses may have seasonal bias
-- 4. Telehealth adoption heavily influenced by COVID-19 pandemic
-- 5. Only includes community-dwelling Medicare beneficiaries

-- Possible extensions:
-- 1. Add demographic breakdowns (age, gender, urban/rural)
-- 2. Compare adoption rates by health status
-- 3. Analyze correlation with healthcare utilization
-- 4. Include pre-2020 technology trends where available
-- 5. Add satisfaction metrics for digital services
-- 6. Segment by Medicare Advantage vs Traditional Medicare

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:44:12.296445
    - Additional Notes: Query requires data from 2020 onwards due to telehealth metrics being introduced that year. Results may be significantly impacted by COVID-19 pandemic effects. Consider seasonality of winter survey data when interpreting results.
    
    */