-- Title: Clinician Quality Measure Coverage Analysis
--
-- Business Purpose:
-- - Analyze breadth and completeness of quality measure reporting across providers
-- - Identify measure reporting gaps and opportunities for improvement
-- - Support quality improvement targeting and provider education initiatives
-- - Enable data quality monitoring and validation efforts

WITH measure_counts AS (
    -- Calculate measure reporting metrics per provider
    SELECT 
        npi,
        provider_last_name,
        provider_first_name,
        COUNT(DISTINCT measure_cd) as total_measures_reported,
        COUNT(DISTINCT CASE WHEN prf_rate IS NOT NULL THEN measure_cd END) as measures_with_performance,
        COUNT(DISTINCT CASE WHEN patient_count >= 20 THEN measure_cd END) as measures_with_sufficient_volume,
        COUNT(DISTINCT CASE WHEN star_value IS NOT NULL THEN measure_cd END) as measures_with_stars
    FROM mimi_ws_1.provdatacatalog.dac_ec_public_reporting
    GROUP BY npi, provider_last_name, provider_first_name
)

SELECT 
    -- Provider identification
    npi,
    provider_last_name,
    provider_first_name,
    
    -- Measure reporting metrics
    total_measures_reported,
    measures_with_performance,
    measures_with_sufficient_volume,
    measures_with_stars,
    
    -- Calculate reporting completeness ratios
    ROUND(measures_with_performance / NULLIF(total_measures_reported, 0) * 100, 1) as pct_measures_with_performance,
    ROUND(measures_with_sufficient_volume / NULLIF(total_measures_reported, 0) * 100, 1) as pct_measures_sufficient_volume,
    ROUND(measures_with_stars / NULLIF(total_measures_reported, 0) * 100, 1) as pct_measures_with_stars
    
FROM measure_counts

-- Focus on providers with significant measure reporting
WHERE total_measures_reported >= 5

-- Order by completeness of reporting
ORDER BY measures_with_performance DESC, total_measures_reported DESC
LIMIT 1000;

-- How this query works:
-- 1. Creates a CTE to aggregate measure reporting metrics per provider
-- 2. Calculates various counts of measure reporting completeness
-- 3. Computes percentage ratios to assess reporting quality
-- 4. Filters and sorts to highlight providers with meaningful reporting volume

-- Assumptions and Limitations:
-- - Assumes NPI is the primary provider identifier
-- - Focuses on providers reporting 5+ measures to ensure meaningful analysis
-- - Does not distinguish between different types of measures (quality vs. PI vs. IA)
-- - Limited to most recent reporting period in the data

-- Possible Extensions:
-- 1. Add measure type analysis (Quality/PI/IA distribution)
-- 2. Include temporal trends by analyzing multiple reporting periods
-- 3. Add geographic or specialty analysis dimensions
-- 4. Compare measure reporting patterns between APM and non-APM providers
-- 5. Analyze specific measure performance within high-reporting providers
-- 6. Add peer group comparisons based on specialty or region
-- 7. Include collection type analysis to understand reporting methods

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:46:15.932529
    - Additional Notes: Query provides high-level overview of clinician reporting compliance and data completeness patterns. Limited to providers with 5+ measures which may exclude some valid reporters. Performance metrics are count-based rather than weighted by importance or impact. Consider data freshness when interpreting results as reporting patterns may vary across submission periods.
    
    */