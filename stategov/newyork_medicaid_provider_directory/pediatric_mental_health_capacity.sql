-- Title: Pediatric Mental Health Provider Capacity Analysis

-- Business Purpose: 
-- Analyze the availability and distribution of pediatric mental health providers
-- in the NY Medicaid network to support strategic planning for children's
-- behavioral health services. This analysis helps identify areas needing
-- additional provider recruitment and supports care coordination initiatives.

WITH pediatric_mh_providers AS (
    -- Filter for relevant mental health providers seeing children
    SELECT 
        provider_or_facility_name,
        profession_or_service,
        provider_specialty,
        county,
        city,
        zip_code,
        file_date,
        CASE 
            WHEN LOWER(provider_specialty) LIKE '%child%' 
                OR LOWER(provider_specialty) LIKE '%pediatric%' THEN 'Child-Focused'
            ELSE 'General'
        END as pediatric_focus
    FROM mimi_ws_1.stategov.newyork_medicaid_provider_directory
    WHERE 
        -- Include relevant provider types
        (LOWER(profession_or_service) LIKE '%mental health%'
        OR LOWER(profession_or_service) LIKE '%psychiatr%'
        OR LOWER(profession_or_service) LIKE '%psycholog%')
        -- Use most recent data
        AND file_date = (SELECT MAX(file_date) 
                        FROM mimi_ws_1.stategov.newyork_medicaid_provider_directory)
)

SELECT 
    county,
    COUNT(DISTINCT provider_or_facility_name) as total_providers,
    SUM(CASE WHEN pediatric_focus = 'Child-Focused' THEN 1 ELSE 0 END) as child_focused_providers,
    COUNT(DISTINCT city) as unique_cities_served,
    COUNT(DISTINCT zip_code) as unique_zipcodes_served,
    ROUND(SUM(CASE WHEN pediatric_focus = 'Child-Focused' THEN 1 ELSE 0 END) * 100.0 / 
          COUNT(DISTINCT provider_or_facility_name), 1) as pct_child_focused
FROM pediatric_mh_providers
GROUP BY county
HAVING total_providers > 0
ORDER BY total_providers DESC, county;

-- How it works:
-- 1. Creates a CTE filtering for mental health providers using profession/specialty
-- 2. Categorizes providers as child-focused based on specialty descriptions
-- 3. Aggregates providers by county with key metrics for capacity analysis
-- 4. Includes geographic spread via distinct cities and zip codes served

-- Assumptions and limitations:
-- - Provider specialty and profession fields accurately capture mental health services
-- - Single location per provider (may miss multiple practice locations)
-- - Current provider status assumed active based on latest file date
-- - Does not account for provider capacity/patient panel size
-- - May include some providers not actively accepting new patients

-- Possible extensions:
-- 1. Add demographic overlay to identify high-need areas based on youth population
-- 2. Include temporal analysis to track provider network changes over time
-- 3. Incorporate distance analysis for accessibility assessment
-- 4. Add provider language capabilities for cultural competency analysis
-- 5. Cross-reference with quality metrics or outcome data where available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:43:59.760372
    - Additional Notes: Query focuses on provider child specialization flags and geographic coverage metrics. Consider validating provider specialty text patterns for completeness, as the child/pediatric keyword matching may miss some relevant providers. Geographic coverage metrics (cities/zipcodes) provide useful context but should be interpreted with regional population density in mind.
    
    */