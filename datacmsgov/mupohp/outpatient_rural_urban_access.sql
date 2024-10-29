-- outpatient_service_geographic_access.sql

-- Business Purpose:
-- Analyzes geographic accessibility of Medicare outpatient hospital services
-- Identifies potential service gaps in rural vs urban areas 
-- Helps healthcare organizations and policymakers understand service distribution
-- Supports strategic planning for new facilities or expanded services

WITH provider_metrics AS (
    -- Aggregate key metrics by provider and location
    SELECT 
        rndrng_prvdr_state_abrvtn as state,
        rndrng_prvdr_ruca_desc as rural_urban_category,
        COUNT(DISTINCT rndrng_prvdr_ccn) as provider_count,
        COUNT(DISTINCT apc_cd) as unique_services,
        SUM(bene_cnt) as total_beneficiaries,
        SUM(capc_srvcs) as total_services,
        AVG(avg_mdcr_pymt_amt) as avg_payment_per_service
    FROM mimi_ws_1.datacmsgov.mupohp
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent full year
    GROUP BY 
        state,
        rural_urban_category
)

SELECT 
    state,
    rural_urban_category,
    provider_count,
    unique_services,
    total_beneficiaries,
    total_services,
    ROUND(total_services * 1.0 / provider_count, 0) as avg_services_per_provider,
    ROUND(total_beneficiaries * 1.0 / provider_count, 0) as avg_beneficiaries_per_provider,
    ROUND(avg_payment_per_service, 2) as avg_payment_per_service
FROM provider_metrics
WHERE provider_count >= 5  -- Filter to ensure statistical significance
ORDER BY 
    state,
    rural_urban_category;

-- How this query works:
-- 1. Aggregates key outpatient service metrics by state and rural/urban classification
-- 2. Calculates per-provider ratios to normalize comparisons
-- 3. Focuses on areas with sufficient provider counts for meaningful analysis
-- 4. Provides a geographic view of service accessibility and utilization

-- Assumptions and Limitations:
-- - Uses 2022 data as the most recent complete year
-- - Requires minimum of 5 providers per geographic segment for inclusion
-- - RUCA codes accurately reflect rural/urban status
-- - Does not account for population density or demographic factors
-- - Medicare-only view may not reflect total market access

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include demographic data to assess service gaps relative to population needs
-- 3. Add distance/drive time analysis for deeper accessibility insights
-- 4. Compare service mix variations between rural and urban providers
-- 5. Incorporate quality metrics to assess access to high-quality care
-- 6. Add hospital ownership type analysis to understand market dynamics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:30:20.435667
    - Additional Notes: Query provides geographic access analysis for Medicare outpatient services with rural/urban comparison. Minimum threshold of 5 providers per segment ensures statistical reliability. Consider state population variations when interpreting results.
    
    */