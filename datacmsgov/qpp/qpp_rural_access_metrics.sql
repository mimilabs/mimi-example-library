-- QPP Rural Healthcare Access and Support Analysis
-- Business Purpose: Analyze QPP participation and performance patterns in rural and 
-- healthcare shortage areas to identify opportunities for improving healthcare access
-- and support for underserved communities.

WITH provider_summary AS (
    -- Get key metrics for rural and shortage area providers
    SELECT 
        practice_state_or_us_territory,
        rural_status,
        health_professional_shortage_area_status,
        clinician_type,
        clinician_specialty,
        COUNT(DISTINCT provider_key) as provider_count,
        AVG(final_score) as avg_final_score,
        AVG(payment_adjustment_percentage) as avg_payment_adjustment,
        AVG(medicare_patients) as avg_medicare_patients,
        COUNT(CASE WHEN nonreporting = true THEN 1 END) as nonreporting_count
    FROM mimi_ws_1.datacmsgov.qpp
    GROUP BY 1,2,3,4,5
),

state_summary AS (
    -- Calculate state-level statistics
    SELECT
        practice_state_or_us_territory,
        COUNT(DISTINCT provider_key) as total_providers,
        SUM(CASE WHEN rural_status = true THEN 1 ELSE 0 END) as rural_providers,
        SUM(CASE WHEN health_professional_shortage_area_status = true THEN 1 ELSE 0 END) as hpsa_providers
    FROM mimi_ws_1.datacmsgov.qpp
    GROUP BY 1
)

SELECT 
    p.practice_state_or_us_territory,
    p.rural_status,
    p.health_professional_shortage_area_status,
    p.clinician_type,
    p.clinician_specialty,
    p.provider_count,
    p.avg_final_score,
    p.avg_payment_adjustment,
    p.avg_medicare_patients,
    p.nonreporting_count,
    s.total_providers,
    s.rural_providers,
    s.hpsa_providers,
    ROUND(s.rural_providers * 100.0 / s.total_providers, 2) as pct_rural_providers,
    ROUND(s.hpsa_providers * 100.0 / s.total_providers, 2) as pct_hpsa_providers
FROM provider_summary p
JOIN state_summary s 
    ON p.practice_state_or_us_territory = s.practice_state_or_us_territory
ORDER BY 
    p.practice_state_or_us_territory,
    p.provider_count DESC;

-- How this query works:
-- 1. Creates a summary of provider metrics grouped by location, rural/HPSA status, and provider type
-- 2. Calculates state-level statistics for context
-- 3. Joins the summaries together to provide a comprehensive view of rural healthcare access

-- Assumptions and Limitations:
-- - Rural_status and HPSA_status fields are accurately reported
-- - Does not account for temporal changes in status
-- - May not capture all factors affecting healthcare access
-- - Medicare patients may not represent total patient population

-- Possible Extensions:
-- 1. Add trending analysis to track changes over time
-- 2. Include analysis of quality measures specific to rural care
-- 3. Incorporate distance to nearest facilities/providers
-- 4. Compare performance between rural and urban providers
-- 5. Analyze impact of telehealth adoption in rural areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:15:43.397639
    - Additional Notes: Query focuses on geographic and demographic disparities in healthcare access by analyzing QPP participation patterns in rural and health professional shortage areas. Performance metrics are aggregated at both provider and state levels to enable comparison across different regions and provider types.
    
    */