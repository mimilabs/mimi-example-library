-- provider_specialization_and_services.sql
-- Purpose: Analyze dental provider specialization and corresponding service patterns to identify:
-- 1. Distribution of specialist vs general dentist visits
-- 2. Most common service combinations by provider type
-- 3. Typical service complexity patterns
-- This analysis helps understand provider capacity, referral needs, and service delivery models

WITH provider_visits AS (
    -- Categorize visits by provider type
    SELECT 
        dvdateyr,
        CASE 
            WHEN gendent = 1 THEN 'General Dentist'
            WHEN dentsurg = 1 THEN 'Dental Surgeon'
            WHEN orthodnt = 1 THEN 'Orthodontist'
            WHEN endodent = 1 THEN 'Endodontist'
            WHEN periodnt = 1 THEN 'Periodontist'
            ELSE 'Other/Multiple'
        END as provider_type,
        
        -- Core services provided
        examine as had_exam,
        clenteth as had_cleaning,
        justxryx as had_xray,
        oralsurx as had_oral_surgery,
        orthdonx as had_orthodontics,
        
        -- Calculate service complexity
        (COALESCE(examine,0) + COALESCE(clenteth,0) + COALESCE(justxryx,0) + 
         COALESCE(filling,0) + COALESCE(rootcanx,0) + COALESCE(oralsurx,0)) as service_count,
        
        dvxp_yy_x as total_payment,
        COUNT(*) OVER (PARTITION BY dupersid, dvdateyr) as visits_per_year
        
    FROM mimi_ws_1.ahrq.meps_event_dentalvisits
    WHERE dvdateyr >= 2018  -- Focus on recent years
)

SELECT 
    dvdateyr as year,
    provider_type,
    COUNT(*) as visit_count,
    ROUND(AVG(service_count),2) as avg_services_per_visit,
    ROUND(AVG(had_exam)*100,1) as pct_with_exam,
    ROUND(AVG(had_cleaning)*100,1) as pct_with_cleaning,
    ROUND(AVG(had_xray)*100,1) as pct_with_xray,
    ROUND(AVG(total_payment),2) as avg_payment,
    ROUND(AVG(visits_per_year),2) as avg_visits_per_patient_year
FROM provider_visits
GROUP BY dvdateyr, provider_type
ORDER BY dvdateyr DESC, visit_count DESC;

-- How it works:
-- 1. Creates a CTE to categorize visits by provider type and calculate service metrics
-- 2. Aggregates key metrics by year and provider type
-- 3. Focuses on core services that indicate practice patterns
-- 4. Includes visit frequency and payment data to understand utilization

-- Assumptions and limitations:
-- 1. Provider categories are mutually exclusive (visit assigned to primary provider)
-- 2. Recent years (2018+) are most relevant for current patterns
-- 3. Service complexity is approximated by count of common procedures
-- 4. Does not account for regional variations or facility type

-- Possible extensions:
-- 1. Add geographic analysis to identify regional specialization patterns
-- 2. Include patient demographics to understand specialist access
-- 3. Analyze referral patterns between provider types
-- 4. Compare service mix changes over longer time periods
-- 5. Calculate market concentration by specialist type

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:49:27.029390
    - Additional Notes: The query assumes single primary provider per visit and may undercount multi-provider interactions. Service complexity metric is a simplified approximation based on procedure counts. Results are most reliable for years 2018 onwards due to consistent coding practices.
    
    */