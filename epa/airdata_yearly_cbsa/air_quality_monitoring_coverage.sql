-- Title: CBSA Air Quality Monitoring Coverage Analysis

-- Business Purpose:
-- - Assess the completeness and reliability of air quality monitoring across CBSAs
-- - Identify gaps in air quality monitoring infrastructure
-- - Support decisions on where to expand or optimize monitoring networks
-- - Enable data quality validation for environmental reporting

SELECT 
    year,
    -- Count distinct CBSAs with monitoring data
    COUNT(DISTINCT cbsa_code) as monitored_cbsas,
    
    -- Calculate average monitoring coverage
    AVG(days_with_aqi) as avg_days_monitored,
    
    -- Identify CBSAs with comprehensive monitoring
    COUNT(CASE WHEN days_with_aqi >= 350 THEN 1 END) as cbsas_with_full_coverage,
    
    -- Identify CBSAs with limited monitoring
    COUNT(CASE WHEN days_with_aqi < 250 THEN 1 END) as cbsas_with_limited_coverage,
    
    -- Calculate median AQI across all CBSAs
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY median_aqi) as typical_median_aqi,
    
    -- Count CBSAs with recent data updates
    COUNT(CASE WHEN mimi_src_file_date >= DATE_SUB(CURRENT_DATE(), 180) THEN 1 END) as recently_updated_cbsas

FROM mimi_ws_1.epa.airdata_yearly_cbsa

WHERE year >= 2018  -- Focus on recent years
GROUP BY year
ORDER BY year DESC;

-- How it works:
-- 1. Groups data by year to show temporal trends
-- 2. Calculates key metrics about monitoring coverage and data quality
-- 3. Identifies areas with comprehensive vs limited monitoring
-- 4. Assesses the timeliness of data updates

-- Assumptions and Limitations:
-- - Assumes days_with_aqi is a reliable indicator of monitoring coverage
-- - Does not account for temporary monitoring station outages
-- - May not reflect the actual population covered by monitoring
-- - Recent data may still be preliminary or subject to updates

-- Possible Extensions:
-- 1. Add geographic analysis by joining with CBSA demographic data
-- 2. Include trend analysis to show changes in monitoring coverage
-- 3. Compare monitoring coverage with air quality severity
-- 4. Add seasonal analysis of monitoring patterns
-- 5. Include population-weighted coverage metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:18:05.861694
    - Additional Notes: This query focuses on monitoring infrastructure and data quality assessment rather than air quality levels themselves. It helps identify potential gaps in data collection and areas where monitoring needs improvement. Best used in conjunction with administrative data about monitoring station locations and CBSA population data for comprehensive coverage analysis.
    
    */