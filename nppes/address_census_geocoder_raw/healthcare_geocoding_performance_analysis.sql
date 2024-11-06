
-- File: healthcare_provider_geocoding_match_analysis.sql
-- Purpose: Analyze the effectiveness and coverage of address geocoding for healthcare providers
-- Business Value: Assess data quality, identify geocoding challenges, and support location-based healthcare analytics

WITH geocoding_performance AS (
    -- Aggregate geocoding match performance metrics
    SELECT 
        match_indicator,
        match_type,
        COUNT(*) as address_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
    FROM mimi_ws_1.nppes.address_census_geocoder_raw
    GROUP BY match_indicator, match_type
),

state_geocoding_coverage AS (
    -- Analyze geocoding coverage by state
    SELECT 
        state_fips,
        COUNT(*) as total_addresses,
        SUM(CASE WHEN match_indicator = 'Match' THEN 1 ELSE 0 END) as matched_addresses,
        ROUND(SUM(CASE WHEN match_indicator = 'Match' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as match_rate
    FROM mimi_ws_1.nppes.address_census_geocoder_raw
    GROUP BY state_fips
    ORDER BY match_rate ASC
    LIMIT 10  -- Focus on states with lowest geocoding match rates
)

-- Main query to provide a comprehensive view of geocoding performance
SELECT 
    gp.match_indicator,
    gp.match_type,
    gp.address_count,
    gp.percentage,
    sc.state_fips,
    sc.total_addresses,
    sc.matched_addresses,
    sc.match_rate
FROM geocoding_performance gp
CROSS JOIN state_geocoding_coverage sc
ORDER BY gp.address_count DESC, sc.match_rate ASC;

-- How the Query Works:
-- 1. First CTE (geocoding_performance) calculates overall match performance
-- 2. Second CTE (state_geocoding_coverage) breaks down match rates by state
-- 3. Final query combines both CTEs to provide a holistic view of geocoding effectiveness

-- Assumptions and Limitations:
-- - Assumes geocoding data is current and representative
-- - Limited to available FIPS codes in the dataset
-- - Does not account for address complexity or data preprocessing challenges

-- Potential Extensions:
-- 1. Add longitude/latitude distribution analysis
-- 2. Incorporate address quality scoring
-- 3. Compare geocoding performance across different provider types


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:11:24.472546
    - Additional Notes: This query provides insights into address geocoding match rates and coverage, helping to assess data quality for location-based healthcare analytics. It requires careful interpretation due to potential variations in address formatting and geocoding challenges.
    
    */