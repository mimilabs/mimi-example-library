-- Provider Certification Distribution Analysis
--
-- Business Purpose:
-- Analyze the mix of provider certification levels (30/100/275 patient waivers) across counties
-- to understand provider experience levels and identify opportunities for certification upgrades.
-- This helps target provider education and support programs.

WITH provider_certification_metrics AS (
    SELECT 
        state,
        county,
        -- Calculate percentage of providers at each certification level
        ROUND(number_of_providers_with_30patient_waivers * 100.0 / NULLIF(total_number_of_waivered_providers, 0), 1) as pct_30_patient,
        ROUND(number_of_providers_with_100patient_waivers * 100.0 / NULLIF(total_number_of_waivered_providers, 0), 1) as pct_100_patient,
        ROUND(number_of_providers_with_275patient_waivers * 100.0 / NULLIF(total_number_of_waivered_providers, 0), 1) as pct_275_patient,
        total_number_of_waivered_providers,
        high_need_for_treatment_services
    FROM mimi_ws_1.hhsoig.buprenorphine_countydata
    WHERE total_number_of_waivered_providers > 0  -- Focus on counties with active providers
)

SELECT 
    state,
    COUNT(county) as counties_with_providers,
    ROUND(AVG(pct_30_patient), 1) as avg_pct_30_patient_providers,
    ROUND(AVG(pct_100_patient), 1) as avg_pct_100_patient_providers,
    ROUND(AVG(pct_275_patient), 1) as avg_pct_275_patient_providers,
    SUM(total_number_of_waivered_providers) as total_providers,
    SUM(CASE WHEN high_need_for_treatment_services = true THEN 1 ELSE 0 END) as high_need_counties
FROM provider_certification_metrics
GROUP BY state
ORDER BY total_providers DESC
LIMIT 20;

-- How it works:
-- 1. Creates a CTE to calculate the percentage distribution of providers at each certification level
-- 2. Aggregates the data at the state level to show certification patterns
-- 3. Includes counts of high-need counties for context
-- 4. Orders by total providers to highlight states with largest provider networks

-- Assumptions and limitations:
-- - Assumes non-zero provider counts for percentage calculations
-- - Limited to top 20 states by provider count
-- - Does not account for population differences between states
-- - Historical data from 2018 may not reflect current situation

-- Possible extensions:
-- 1. Add year-over-year comparison of certification levels
-- 2. Include population-adjusted metrics
-- 3. Add filters for urban vs rural counties
-- 4. Compare certification patterns between high-need and other counties
-- 5. Calculate potential capacity increase if providers upgraded certifications

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:44:29.967922
    - Additional Notes: Query focuses on states with most established provider networks (min 1 provider per county) and may not fully represent areas with limited or no coverage. Percentages are only calculated for counties with active providers, which could understate access gaps in completely unserved areas.
    
    */