-- Title: Preventive Healthcare Services Coverage Analysis by ZCTA
-- Business Purpose: Analyze the adoption rates of key preventive healthcare services across 
-- different geographic areas to identify opportunities for improving healthcare access and
-- utilization. This information helps healthcare organizations, policymakers, and community
-- health programs target interventions and resources effectively.

WITH preventive_measures AS (
    -- Filter and select key preventive healthcare measures
    SELECT 
        location_name as zcta,
        measure,
        data_value as adoption_rate,
        total_population,
        low_confidence_limit,
        high_confidence_limit
    FROM mimi_ws_1.cdc.places_zcta
    WHERE category = 'Prevention'
    AND year = 2023  -- Most recent year
    AND data_value IS NOT NULL
),

ranked_areas AS (
    -- Rank ZCTAs by preventive service adoption
    SELECT 
        zcta,
        measure,
        adoption_rate,
        total_population,
        -- Calculate the statistical reliability
        (high_confidence_limit - low_confidence_limit) as confidence_interval_width,
        -- Rank areas within each measure
        DENSE_RANK() OVER (PARTITION BY measure ORDER BY adoption_rate DESC) as rank
    FROM preventive_measures
)

-- Final output with key insights
SELECT 
    measure as preventive_service,
    COUNT(DISTINCT zcta) as total_areas,
    ROUND(AVG(adoption_rate), 1) as avg_adoption_rate,
    ROUND(MIN(adoption_rate), 1) as min_adoption_rate,
    ROUND(MAX(adoption_rate), 1) as max_adoption_rate,
    ROUND(AVG(confidence_interval_width), 2) as avg_confidence_interval,
    -- Count areas with concerning low adoption
    COUNT(CASE WHEN adoption_rate < 50 THEN 1 END) as areas_below_50_percent
FROM ranked_areas
GROUP BY measure
ORDER BY avg_adoption_rate DESC;

-- How it works:
-- 1. First CTE filters for preventive healthcare measures and relevant columns
-- 2. Second CTE adds rankings and statistical calculations
-- 3. Final query aggregates data to provide a summary view of preventive service adoption

-- Assumptions and Limitations:
-- 1. Assumes 2023 data is complete and accurate
-- 2. Does not account for demographic or socioeconomic factors
-- 3. Confidence interval width used as a proxy for estimate reliability
-- 4. 50% threshold is an arbitrary cutoff for "low adoption"

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify regional patterns
-- 2. Compare against state or national averages
-- 3. Incorporate year-over-year trends
-- 4. Add population-weighted averages
-- 5. Break down by population size categories
-- 6. Include correlation analysis with health outcomes
-- 7. Add demographic factors from additional data sources

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:32:03.366647
    - Additional Notes: Query focuses on preventive healthcare service adoption rates across ZCTAs. Results include aggregate statistics like average adoption rates, confidence intervals, and identification of areas with low preventive care utilization. Note that the Prevention category filter assumes standard CDC PLACES dataset categorization.
    
    */