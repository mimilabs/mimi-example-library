-- Title: SNF License Age and Experience Analysis

-- Business Purpose:
-- This analysis examines the operational maturity and experience of Skilled Nursing Facilities
-- by analyzing their incorporation dates to understand:
-- 1. The age distribution of SNF licenses/operations
-- 2. Market entry patterns over time
-- 3. Potential correlation between facility age and organizational structure
-- This helps identify market maturity, provider experience levels, and potential consolidation opportunities

WITH facility_age AS (
    -- Calculate facility age and group into meaningful buckets
    SELECT 
        YEAR(incorporation_date) as incorporation_year,
        DATEDIFF(YEAR, incorporation_date, CURRENT_DATE) as facility_age_years,
        CASE 
            WHEN DATEDIFF(YEAR, incorporation_date, CURRENT_DATE) < 5 THEN 'New (0-5 years)'
            WHEN DATEDIFF(YEAR, incorporation_date, CURRENT_DATE) < 10 THEN 'Developing (5-10 years)'
            WHEN DATEDIFF(YEAR, incorporation_date, CURRENT_DATE) < 20 THEN 'Established (10-20 years)'
            ELSE 'Mature (20+ years)'
        END as maturity_segment,
        organization_type_structure,
        proprietary_nonprofit,
        state,
        COUNT(*) as facility_count
    FROM mimi_ws_1.datacmsgov.pc_snf
    WHERE incorporation_date IS NOT NULL
    GROUP BY 1,2,3,4,5,6
)

SELECT 
    maturity_segment,
    organization_type_structure,
    proprietary_nonprofit,
    COUNT(*) as total_facilities,
    COUNT(DISTINCT state) as states_present,
    ROUND(AVG(facility_age_years),1) as avg_age_years,
    MIN(incorporation_year) as earliest_incorporation,
    MAX(incorporation_year) as latest_incorporation
FROM facility_age
GROUP BY 1,2,3
ORDER BY maturity_segment, total_facilities DESC;

-- How it works:
-- 1. Creates a CTE that calculates facility age and assigns maturity segments
-- 2. Groups facilities by their maturity level, org structure, and profit status
-- 3. Provides key metrics about facility counts, geographic spread, and age characteristics
-- 4. Orders results to show natural progression from newer to mature facilities

-- Assumptions and Limitations:
-- 1. Relies on incorporation_date being accurately recorded
-- 2. Does not account for ownership changes or acquisitions
-- 3. Incorporation date may not always reflect actual operational start date
-- 4. Missing incorporation dates are excluded from analysis

-- Possible Extensions:
-- 1. Add geographic analysis to identify regions with aging vs newer facilities
-- 2. Include size metrics (if available) to correlate facility age with scale
-- 3. Cross-reference with quality metrics to analyze age vs performance
-- 4. Add temporal analysis to identify peak periods of market entry
-- 5. Include financial performance correlation if metrics become available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:18:25.262825
    - Additional Notes: Query requires valid incorporation_date values in the source table. Results show facility age distribution and organizational characteristics segmented by maturity levels. Care should be taken when interpreting results as incorporation dates may not always align with actual operational start dates.
    
    */