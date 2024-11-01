-- Title: Medicare Outpatient Service Accessibility Analysis

-- Business Purpose: 
-- This query analyzes the geographic distribution of Medicare outpatient services
-- to identify potential access gaps and service concentration patterns.
-- It examines the relationship between beneficiary counts and service volumes
-- to highlight areas that may need additional outpatient service capacity.

WITH service_density AS (
    -- Calculate service density metrics by state
    SELECT 
        rndrng_prvdr_geo_desc as state_name,
        SUM(bene_cnt) as total_beneficiaries,
        SUM(capc_srvcs) as total_services,
        COUNT(DISTINCT apc_cd) as unique_service_types,
        ROUND(SUM(capc_srvcs) / SUM(bene_cnt), 2) as services_per_beneficiary
    FROM mimi_ws_1.datacmsgov.mupohp_geo
    WHERE rndrng_prvdr_geo_lvl = 'State'
    AND mimi_src_file_date = '2022-12-31'  -- Most recent year
    GROUP BY rndrng_prvdr_geo_desc
)

SELECT 
    state_name,
    total_beneficiaries,
    total_services,
    unique_service_types,
    services_per_beneficiary,
    -- Classify states based on service density
    CASE 
        WHEN services_per_beneficiary > 
            (SELECT AVG(services_per_beneficiary) * 1.2 FROM service_density)
        THEN 'High Service Density'
        WHEN services_per_beneficiary < 
            (SELECT AVG(services_per_beneficiary) * 0.8 FROM service_density)
        THEN 'Low Service Density'
        ELSE 'Average Service Density'
    END as service_density_category
FROM service_density
ORDER BY services_per_beneficiary DESC;

-- How the Query Works:
-- 1. Creates a CTE to calculate key service density metrics by state
-- 2. Calculates total beneficiaries, services, and unique service types
-- 3. Derives services per beneficiary ratio
-- 4. Classifies states into density categories based on deviation from mean
-- 5. Orders results by service density to highlight potential access gaps

-- Assumptions and Limitations:
-- 1. Assumes even distribution of services within each state
-- 2. Does not account for demographic differences between states
-- 3. Uses simple thresholds (±20% from mean) for density categorization
-- 4. Limited to one year of data (2022)

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Incorporate population demographics
-- 3. Add geographic clustering analysis
-- 4. Include cost metrics to analyze service accessibility vs. cost
-- 5. Compare with Medicare Advantage penetration rates
-- 6. Add specific service type (APC) distribution analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:09:27.148087
    - Additional Notes: Query focuses on state-level access patterns and might need adjustment of density thresholds (currently set at ±20% from mean) based on specific use cases. Consider population density factors when interpreting results.
    
    */