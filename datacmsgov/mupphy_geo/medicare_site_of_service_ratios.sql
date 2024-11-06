-- medicare_geographic_service_shift_analysis.sql

-- Business Purpose: Analyze shifts in care delivery settings (facility vs non-facility) across states
-- to identify:
-- 1. Market opportunities for outpatient/office-based service expansion
-- 2. Regional variations in site-of-service utilization patterns
-- 3. Cost implications of service location differences
-- 4. Potential areas for value-based care program development

WITH service_location_metrics AS (
    -- Calculate key metrics by state and service location
    SELECT 
        rndrng_prvdr_geo_desc AS state,
        place_of_srvc,
        COUNT(DISTINCT hcpcs_cd) AS unique_services,
        SUM(tot_benes) AS total_beneficiaries,
        SUM(tot_srvcs) AS total_services,
        AVG(avg_mdcr_pymt_amt) AS avg_medicare_payment,
        SUM(tot_rndrng_prvdrs) AS total_providers
    FROM mimi_ws_1.datacmsgov.mupphy_geo
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
        AND rndrng_prvdr_geo_lvl = 'State'   -- State-level analysis
        AND rndrng_prvdr_geo_desc NOT IN ('Unknown', 'Foreign Country')
    GROUP BY 1, 2
),

state_proportions AS (
    -- Calculate proportion of services by location for each state
    SELECT 
        state,
        MAX(CASE WHEN place_of_srvc = 'F' THEN total_services ELSE 0 END) AS facility_services,
        MAX(CASE WHEN place_of_srvc = 'O' THEN total_services ELSE 0 END) AS office_services,
        MAX(CASE WHEN place_of_srvc = 'F' THEN avg_medicare_payment ELSE 0 END) AS facility_payment,
        MAX(CASE WHEN place_of_srvc = 'O' THEN avg_medicare_payment ELSE 0 END) AS office_payment,
        MAX(CASE WHEN place_of_srvc = 'F' THEN total_providers ELSE 0 END) AS facility_providers,
        MAX(CASE WHEN place_of_srvc = 'O' THEN total_providers ELSE 0 END) AS office_providers
    FROM service_location_metrics
    GROUP BY 1
)

-- Final output with key metrics and ratios
SELECT 
    state,
    facility_services,
    office_services,
    ROUND(office_services / (facility_services + office_services) * 100, 2) AS pct_office_services,
    ROUND(facility_payment, 2) AS avg_facility_payment,
    ROUND(office_payment, 2) AS avg_office_payment,
    ROUND((facility_payment - office_payment) / office_payment * 100, 2) AS pct_payment_differential,
    facility_providers,
    office_providers
FROM state_proportions
WHERE facility_services > 0 AND office_services > 0  -- Ensure both settings present
ORDER BY pct_office_services DESC;

-- How this query works:
-- 1. First CTE aggregates basic metrics by state and service location
-- 2. Second CTE pivots the data to compare facility vs office metrics
-- 3. Final query calculates key ratios and percentages for analysis

-- Assumptions and limitations:
-- 1. Uses most recent year (2022) data only
-- 2. Excludes Unknown and Foreign Country records
-- 3. Requires services to be present in both settings
-- 4. Does not account for service complexity differences
-- 5. Payment differentials may reflect case mix variations

-- Possible extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include specific HCPCS code analysis for top procedures
-- 3. Incorporate demographic factors
-- 4. Add geographic clustering analysis
-- 5. Compare against quality metrics or outcomes data
-- 6. Analyze specific specialty or service line patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:25:59.313812
    - Additional Notes: Query focuses specifically on facility vs non-facility service distribution patterns and associated cost differentials across states. Results are most meaningful for services commonly performed in both settings. Payment differentials should be interpreted with caution as they may reflect differences in patient complexity and service mix rather than just location effects.
    
    */