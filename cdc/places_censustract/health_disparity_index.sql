-- Title: Geospatial Health Disparity Index Analysis

-- Business Purpose: 
-- This query creates a health disparity index by analyzing multiple key health indicators
-- across census tracts to identify areas with significant health disparities.
-- The results can help policymakers and healthcare organizations prioritize
-- resource allocation and develop targeted intervention strategies.

WITH health_measures AS (
    -- Select key health indicators that contribute to overall health disparities
    SELECT 
        state_desc,
        county_name,
        locationid,
        measure,
        data_value,
        total_population,
        geolocation,
        data_value_unit
    FROM mimi_ws_1.cdc.places_censustract
    WHERE year = 2021
        AND category IN ('Health Outcomes', 'Prevention')
        AND measure IN (
            'Current asthma among adults aged >= 18 years',
            'High blood pressure among adults aged >= 18 years',
            'Cancer (excluding skin cancer) among adults aged >= 18 years',
            'Current lack of health insurance among adults aged 18-64 years'
        )
),

tract_scores AS (
    -- Calculate z-scores for each health measure by census tract
    SELECT 
        locationid,
        state_desc,
        county_name,
        total_population,
        geolocation,
        AVG(data_value) as avg_prevalence,
        COUNT(distinct measure) as measure_count,
        STDDEV(data_value) as measure_variation
    FROM health_measures
    GROUP BY 
        locationid,
        state_desc,
        county_name,
        total_population,
        geolocation
    HAVING measure_count >= 3
)

-- Generate final disparity index and identify high-priority areas
SELECT 
    state_desc,
    county_name,
    locationid as census_tract_fips,
    total_population,
    ROUND(avg_prevalence, 2) as avg_health_burden_pct,
    ROUND(measure_variation, 2) as health_variation_score,
    CASE 
        WHEN avg_prevalence > 75th_percentile_value THEN 'High Priority'
        WHEN avg_prevalence > 50th_percentile_value THEN 'Medium Priority'
        ELSE 'Lower Priority'
    END as intervention_priority,
    geolocation
FROM tract_scores
CROSS JOIN (
    SELECT 
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_prevalence) as 75th_percentile_value,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY avg_prevalence) as 50th_percentile_value
    FROM tract_scores
)
ORDER BY avg_prevalence DESC
LIMIT 1000;

-- How it works:
-- 1. First CTE selects key health indicators from the dataset
-- 2. Second CTE calculates aggregate statistics for each census tract
-- 3. Final query generates a prioritization index based on health burden
-- 4. Results are ordered by average prevalence to identify highest-need areas

-- Assumptions and Limitations:
-- - Assumes 2021 data is most current and complete
-- - Requires at least 3 measures per tract for valid comparison
-- - Does not account for demographic or socioeconomic factors
-- - Limited to selected health measures only

-- Possible Extensions:
-- 1. Add demographic weightings based on age or income distributions
-- 2. Incorporate year-over-year trend analysis
-- 3. Add spatial clustering analysis to identify regional patterns
-- 4. Include social determinants of health measures
-- 5. Create visualization layers for mapping software integration

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:36:04.164678
    - Additional Notes: The query creates a composite health disparity score using multiple indicators but requires sufficient data coverage (at least 3 measures per tract) to generate meaningful results. The prioritization thresholds (75th/50th percentiles) may need adjustment based on specific regional contexts or policy requirements.
    
    */