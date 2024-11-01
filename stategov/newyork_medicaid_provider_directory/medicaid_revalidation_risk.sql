-- Title: Medicaid Provider Service Continuity Risk Analysis
-- Business Purpose: Identify providers with upcoming revalidation deadlines and assess 
-- potential service disruption risks, focusing on critical specialties and medically fragile populations.
-- This helps healthcare administrators proactively manage provider revalidation
-- and maintain continuous care coverage.

WITH provider_revalidation AS (
    -- Get providers with revalidation dates in next 90 days
    SELECT 
        provider_or_facility_name,
        medicaid_type,
        profession_or_service,
        provider_specialty,
        county,
        next_anticipated_revalidation_date,
        medically_fragile_children_and_adults_directory_ind,
        DATEDIFF(next_anticipated_revalidation_date, CURRENT_DATE()) as days_until_revalidation
    FROM mimi_ws_1.stategov.newyork_medicaid_provider_directory
    WHERE file_date = (SELECT MAX(file_date) FROM mimi_ws_1.stategov.newyork_medicaid_provider_directory)
    AND next_anticipated_revalidation_date IS NOT NULL 
    AND next_anticipated_revalidation_date <= DATEADD(day, 90, CURRENT_DATE())
),

county_specialty_counts AS (
    -- Calculate specialty provider counts by county
    SELECT 
        county,
        provider_specialty,
        COUNT(*) as total_providers,
        SUM(CASE WHEN medically_fragile_children_and_adults_directory_ind = 'Y' THEN 1 ELSE 0 END) as fragile_care_providers
    FROM provider_revalidation
    GROUP BY county, provider_specialty
)

-- Final output combining revalidation risks with county context
SELECT 
    pr.county,
    pr.provider_specialty,
    pr.provider_or_facility_name,
    pr.days_until_revalidation,
    pr.medically_fragile_children_and_adults_directory_ind as serves_fragile_populations,
    csc.total_providers as county_specialty_providers,
    csc.fragile_care_providers as county_fragile_care_providers,
    CASE 
        WHEN pr.medically_fragile_children_and_adults_directory_ind = 'Y' 
        AND csc.fragile_care_providers <= 3 THEN 'HIGH'
        WHEN pr.days_until_revalidation <= 30 THEN 'MEDIUM'
        ELSE 'LOW'
    END as risk_level
FROM provider_revalidation pr
JOIN county_specialty_counts csc 
    ON pr.county = csc.county 
    AND pr.provider_specialty = csc.provider_specialty
ORDER BY 
    risk_level DESC,
    days_until_revalidation ASC;

-- How it works:
-- 1. Identifies providers due for revalidation in next 90 days
-- 2. Calculates provider counts by county and specialty
-- 3. Assigns risk levels based on revalidation timing and service to fragile populations
-- 4. Prioritizes providers based on risk level and revalidation urgency

-- Assumptions and limitations:
-- - Assumes current provider data is accurate and complete
-- - Risk assessment is simplified and may need refinement
-- - Does not account for provider capacity or patient volume
-- - Limited to 90-day forward-looking window

-- Possible extensions:
-- 1. Add historical revalidation success rates
-- 2. Include geographic distance to nearest alternative provider
-- 3. Incorporate patient population demographics
-- 4. Add provider capacity metrics
-- 5. Create automated alerts for high-risk situations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:27:29.342674
    - Additional Notes: Query focuses on revalidation deadlines within a 90-day window and prioritizes providers serving medically fragile populations. Risk assessment is based on revalidation timing and provider scarcity at county level. Regular updates to the source table are required for accurate risk assessment.
    
    */