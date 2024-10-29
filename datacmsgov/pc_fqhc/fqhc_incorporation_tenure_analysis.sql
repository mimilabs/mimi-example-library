-- TITLE: FQHC Integration Date and Service Longevity Analysis

-- BUSINESS PURPOSE:
-- Analyzes FQHC incorporation patterns and operating tenure to understand:
-- - Market maturity and stability across regions
-- - Historical waves of FQHC establishment
-- - Correlation between operating experience and organization type
-- - Potential areas needing new FQHC development
-- This information helps identify market opportunities and assess provider experience.

SELECT 
    -- Get incorporation year for time-based grouping
    YEAR(incorporation_date) as incorporation_year,
    
    -- Capture key organizational attributes
    organization_type_structure,
    proprietary_nonprofit,
    state,
    
    -- Count unique FQHCs and calculate percentages
    COUNT(DISTINCT enrollment_id) as num_fqhcs,
    ROUND(COUNT(DISTINCT enrollment_id) * 100.0 / SUM(COUNT(DISTINCT enrollment_id)) OVER (), 2) as pct_of_total,
    
    -- Calculate average years in operation
    ROUND(AVG(DATEDIFF(current_date(), incorporation_date)/365.25), 1) as avg_years_operating

FROM mimi_ws_1.datacmsgov.pc_fqhc

-- Focus on records with valid incorporation dates
WHERE incorporation_date IS NOT NULL

GROUP BY 
    incorporation_year,
    organization_type_structure,
    proprietary_nonprofit,
    state

-- Order by incorporation year to show historical progression
ORDER BY 
    incorporation_year,
    state,
    num_fqhcs DESC;

-- HOW IT WORKS:
-- 1. Groups FQHCs by incorporation year, org type, profit status and state
-- 2. Calculates counts and percentages of FQHCs in each group
-- 3. Determines average operating tenure based on incorporation date
-- 4. Orders results chronologically to show establishment patterns

-- ASSUMPTIONS & LIMITATIONS:
-- - Relies on accurate incorporation dates in the source data
-- - Does not account for FQHCs that have closed or merged
-- - Operating tenure calculation assumes continuous operation since incorporation
-- - Current date used for tenure calculation may need periodic updates

-- POSSIBLE EXTENSIONS:
-- 1. Add cohort analysis comparing performance metrics by incorporation period
-- 2. Include geographic clustering analysis to identify expansion patterns
-- 3. Correlate operating tenure with size metrics (multiple locations, NPIs)
-- 4. Add demographic overlay to assess relationship between FQHC age and community needs
-- 5. Compare incorporation trends during different policy/regulatory periods

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:19:58.803783
    - Additional Notes: Query performs time-series analysis of FQHC establishment patterns and may have longer execution time due to date calculations across the full dataset. Results accuracy depends on completeness of incorporation_date field. Consider adding date range filters if analyzing specific time periods.
    
    */