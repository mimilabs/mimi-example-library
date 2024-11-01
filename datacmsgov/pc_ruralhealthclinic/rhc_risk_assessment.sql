-- rhc_service_continuity_analysis.sql

-- Business Purpose:
-- This query analyzes the service continuity risk profile of Rural Health Clinics (RHCs)
-- by examining their operational characteristics to help:
-- - Identify potential service gaps in rural healthcare delivery
-- - Assess the stability of RHC operations
-- - Support rural healthcare access planning
-- - Guide resource allocation for rural health initiatives

WITH active_rhcs AS (
    -- Get the most recent snapshot of active RHCs
    SELECT DISTINCT
        organization_name,
        state,
        city,
        organization_type_structure,
        proprietary_nonprofit,
        multiple_npi_flag,
        incorporation_date,
        mimi_src_file_date
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic)
),

service_risk_metrics AS (
    -- Calculate key risk indicators
    SELECT 
        state,
        COUNT(*) as total_rhcs,
        SUM(CASE WHEN proprietary_nonprofit = 'P' THEN 1 ELSE 0 END) as proprietary_count,
        SUM(CASE WHEN multiple_npi_flag = 'Y' THEN 1 ELSE 0 END) as multi_npi_count,
        ROUND(AVG(DATEDIFF(CURRENT_DATE(), incorporation_date)/365.25), 1) as avg_years_operation
    FROM active_rhcs
    WHERE incorporation_date IS NOT NULL
    GROUP BY state
)

SELECT 
    state,
    total_rhcs,
    proprietary_count,
    ROUND(100.0 * proprietary_count / total_rhcs, 1) as proprietary_pct,
    multi_npi_count,
    ROUND(100.0 * multi_npi_count / total_rhcs, 1) as multi_npi_pct,
    avg_years_operation,
    -- Create a simple risk score based on key metrics
    CASE 
        WHEN (proprietary_count::FLOAT / total_rhcs > 0.7 
              OR multi_npi_count::FLOAT / total_rhcs < 0.2 
              OR avg_years_operation < 5) THEN 'High'
        WHEN (proprietary_count::FLOAT / total_rhcs > 0.5 
              OR multi_npi_count::FLOAT / total_rhcs < 0.3 
              OR avg_years_operation < 10) THEN 'Medium'
        ELSE 'Low'
    END as service_continuity_risk
FROM service_risk_metrics
WHERE total_rhcs >= 5  -- Focus on states with meaningful RHC presence
ORDER BY total_rhcs DESC;

-- How it works:
-- 1. Creates a base table of active RHCs from the most recent data snapshot
-- 2. Calculates key metrics by state that could indicate service continuity risks
-- 3. Generates a simple risk score based on ownership structure, operational complexity, and maturity
-- 4. Presents results ordered by RHC concentration to highlight areas of greatest impact

-- Assumptions and Limitations:
-- - Uses current snapshot only; historical trends not considered
-- - Risk scoring is simplified and would benefit from additional validation
-- - Small states may show skewed percentages due to low RHC counts
-- - Incorporation date may not perfectly reflect operational history

-- Possible Extensions:
-- 1. Add year-over-year change analysis to identify emerging trends
-- 2. Include geographic distance analysis to assess coverage gaps
-- 3. Incorporate demographic data to assess population impact
-- 4. Add financial indicators if available
-- 5. Create more sophisticated risk scoring using weighted factors
-- 6. Include seasonal analysis for tourist-dependent areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:15:49.678231
    - Additional Notes: Query calculates service continuity risk scores for Rural Health Clinics based on ownership type, operational complexity, and age. Risk assessment uses simplified scoring model with thresholds at 5 and 10 years of operation. Requires minimum of 5 RHCs per state for meaningful analysis. Results reflect most recent data snapshot only.
    
    */