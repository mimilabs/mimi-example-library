-- Title: APM Participation Analysis: Distribution and Measure Performance
-- Business Purpose:
-- - Analyze clinician participation patterns across Alternative Payment Models (APMs)
-- - Evaluate measure performance differences between APM and non-APM participants
-- - Support strategic decisions for value-based care program participation
-- - Identify opportunities for expanding APM participation

WITH apm_participation AS (
    -- Identify unique providers and their APM participation status
    SELECT 
        npi,
        provider_last_name,
        provider_first_name,
        CASE 
            WHEN apm_affl_1 IS NOT NULL OR apm_affl_2 IS NOT NULL 
                 OR apm_affl_3 IS NOT NULL OR apm_affl_4 IS NOT NULL 
            THEN 'APM Participant'
            ELSE 'Non-APM Participant'
        END as apm_status,
        COALESCE(apm_affl_1, apm_affl_2, apm_affl_3, apm_affl_4) as primary_apm
    FROM mimi_ws_1.provdatacatalog.dac_ec_public_reporting
    GROUP BY 
        npi,
        provider_last_name,
        provider_first_name,
        apm_status,
        primary_apm
),

performance_metrics AS (
    -- Calculate average performance metrics by APM status
    SELECT 
        ap.apm_status,
        COUNT(DISTINCT ap.npi) as provider_count,
        AVG(pr.prf_rate) as avg_performance_rate,
        AVG(pr.star_value) as avg_star_rating,
        COUNT(DISTINCT pr.measure_cd) as unique_measures
    FROM apm_participation ap
    LEFT JOIN mimi_ws_1.provdatacatalog.dac_ec_public_reporting pr
        ON ap.npi = pr.npi
    WHERE pr.prf_rate IS NOT NULL
    GROUP BY ap.apm_status
)

-- Final output combining participation and performance metrics
SELECT 
    pm.apm_status,
    pm.provider_count,
    ROUND(pm.provider_count * 100.0 / SUM(pm.provider_count) OVER(), 2) as pct_of_total,
    ROUND(pm.avg_performance_rate, 2) as avg_performance_rate,
    ROUND(pm.avg_star_rating, 2) as avg_star_rating,
    pm.unique_measures
FROM performance_metrics pm
ORDER BY pm.provider_count DESC;

-- How it works:
-- 1. First CTE identifies unique providers and their APM participation status
-- 2. Second CTE calculates key performance metrics by APM status
-- 3. Final query combines and formats results with percentage calculations

-- Assumptions and Limitations:
-- - Assumes APM affiliations are current and accurate
-- - Only includes providers with valid performance rates
-- - Does not account for temporal changes in APM participation
-- - May include duplicate measures per provider

-- Possible Extensions:
-- 1. Add geographic analysis of APM participation
-- 2. Break down by specific APM types
-- 3. Include trend analysis across multiple time periods
-- 4. Add measure-specific performance comparisons
-- 5. Incorporate specialty-specific analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:53:08.114755
    - Additional Notes: Query focuses on comparing performance between APM and non-APM participants, providing participation rates and average performance metrics. Results are aggregated at provider level, which may mask individual measure variations. Performance calculations exclude providers with null performance rates.
    
    */