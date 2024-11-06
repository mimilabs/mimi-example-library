-- Title: Geographic Performance Variation Analysis

-- Business Purpose:
-- - Analyze regional variations in clinician quality performance
-- - Identify geographic areas with high/low performing providers 
-- - Support targeted quality improvement and network development
-- - Guide regional expansion and market entry strategies

WITH provider_location AS (
    -- Extract state from provider names to approximate geographic location
    -- Note: In a real implementation, would join to provider address table
    SELECT DISTINCT
        npi,
        provider_last_name,
        provider_first_name,
        RIGHT(measure_cd, 2) as state_code
    FROM mimi_ws_1.provdatacatalog.dac_ec_public_reporting
    WHERE measure_cd LIKE '%_STATE'
),

performance_metrics AS (
    -- Calculate core performance metrics by provider
    SELECT 
        p.npi,
        p.state_code,
        AVG(CAST(r.prf_rate AS FLOAT)) as avg_performance_rate,
        AVG(CAST(r.star_value AS FLOAT)) as avg_star_rating,
        COUNT(DISTINCT r.measure_cd) as measure_count,
        SUM(r.patient_count) as total_patients
    FROM provider_location p
    JOIN mimi_ws_1.provdatacatalog.dac_ec_public_reporting r
        ON p.npi = r.npi
    WHERE r.prf_rate IS NOT NULL
        AND r.star_value IS NOT NULL
    GROUP BY p.npi, p.state_code
)

-- Generate state-level summary statistics
SELECT 
    state_code,
    COUNT(DISTINCT npi) as provider_count,
    ROUND(AVG(avg_performance_rate), 2) as state_avg_performance,
    ROUND(AVG(avg_star_rating), 2) as state_avg_stars,
    ROUND(AVG(measure_count), 1) as avg_measures_per_provider,
    SUM(total_patients) as total_state_patients,
    ROUND(SUM(total_patients) * 1.0 / COUNT(DISTINCT npi), 0) as avg_patients_per_provider
FROM performance_metrics
GROUP BY state_code
HAVING COUNT(DISTINCT npi) >= 10  -- Filter for states with meaningful sample sizes
ORDER BY state_avg_stars DESC

-- How this works:
-- 1. First CTE extracts state codes from measure_cd field (proxy for location)
-- 2. Second CTE calculates provider-level performance metrics
-- 3. Final query aggregates to state level with key quality indicators
-- 4. Results show geographic performance patterns and variations

-- Assumptions and Limitations:
-- - Uses measure_cd state codes as proxy for provider location
-- - Requires minimum provider count per state for statistical validity
-- - Assumes performance rates and star values are comparable across measures
-- - Does not account for case mix or social determinants of health
-- - Limited to providers with complete performance data

-- Possible Extensions:
-- 1. Add time trend analysis by incorporating mimi_src_file_date
-- 2. Break down by specific measure types or clinical areas
-- 3. Include APM participation analysis by state
-- 4. Add statistical significance testing for state differences
-- 5. Create geographic clusters or regions for broader patterns
-- 6. Compare urban vs rural performance variations
-- 7. Incorporate demographic and socioeconomic factors

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:42:28.402841
    - Additional Notes: Query uses state codes derived from measure_cd as a proxy for provider location. For production use, recommend joining to a provider address/location table for more accurate geographic analysis. Minimum threshold of 10 providers per state may need adjustment based on specific analysis needs.
    
    */