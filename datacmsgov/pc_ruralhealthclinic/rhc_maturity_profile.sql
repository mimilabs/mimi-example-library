-- rhc_operational_stability.sql

-- Business Purpose:
-- This query assesses the operational stability and maturity of Rural Health Clinics (RHCs)
-- by analyzing key indicators to help:
-- - Identify established vs newer RHCs based on incorporation dates
-- - Compare organizational structures and business models
-- - Evaluate consistency of business names and operating models
-- - Support strategic planning and resource allocation decisions

WITH maturity_metrics AS (
    SELECT 
        -- Calculate operational age and maturity indicators
        DATEDIFF(YEAR, incorporation_date, CURRENT_DATE) as years_in_operation,
        organization_type_structure,
        proprietary_nonprofit,
        CASE 
            WHEN organization_name = doing_business_as_name THEN 'Same'
            WHEN doing_business_as_name IS NULL THEN 'No DBA'
            ELSE 'Different'
        END as name_consistency,
        COUNT(*) as clinic_count
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic
    WHERE incorporation_date IS NOT NULL
    GROUP BY 1,2,3,4
)

SELECT 
    -- Categorize operational maturity
    CASE 
        WHEN years_in_operation >= 20 THEN 'Established (20+ years)'
        WHEN years_in_operation >= 10 THEN 'Mature (10-19 years)'
        WHEN years_in_operation >= 5 THEN 'Growing (5-9 years)'
        ELSE 'New (<5 years)'
    END as operational_maturity,
    
    -- Business model indicators
    organization_type_structure,
    proprietary_nonprofit as ownership_type,
    name_consistency,
    
    -- Metrics
    COUNT(DISTINCT clinic_count) as unique_clinics,
    AVG(years_in_operation) as avg_years_operating,
    
    -- Calculate percentage distribution
    ROUND(100.0 * COUNT(DISTINCT clinic_count) / 
        SUM(COUNT(DISTINCT clinic_count)) OVER(), 2) as pct_of_total

FROM maturity_metrics
GROUP BY 1,2,3,4
ORDER BY unique_clinics DESC;

-- How the Query Works:
-- 1. Creates a CTE to calculate basic operational metrics for each RHC
-- 2. Categorizes RHCs by operational maturity based on years since incorporation
-- 3. Analyzes business model consistency through name matching and org structure
-- 4. Provides distribution metrics to understand market composition

-- Assumptions and Limitations:
-- - Relies on incorporation_date being accurate and populated
-- - Does not account for ownership changes or restructuring
-- - Assumes current operational status based on presence in dataset
-- - Name consistency may not fully reflect operational complexity

-- Possible Extensions:
-- 1. Add geographic analysis to identify regional maturity patterns
-- 2. Include trend analysis by comparing across multiple quarters
-- 3. Incorporate financial metrics if available
-- 4. Add risk scoring based on operational stability indicators
-- 5. Compare maturity profiles between proprietary and non-profit clinics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:07:04.168182
    - Additional Notes: This query requires valid incorporation_date values to generate meaningful results and may undercount total clinics if incorporation dates are missing. The years_in_operation calculation uses the current date as reference point, so results will shift over time. Consider adding date parameters for point-in-time analysis.
    
    */