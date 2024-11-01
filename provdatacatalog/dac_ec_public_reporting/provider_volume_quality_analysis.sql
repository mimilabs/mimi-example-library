-- Title: Patient Volume and Star Rating Analysis by Provider Specialty
--
-- Business Purpose:
-- - Identify high-volume providers and their quality performance (star ratings)
-- - Support network adequacy and provider engagement strategies
-- - Uncover potential correlations between patient volume and quality metrics
-- - Inform value-based contract negotiations

-- First, calculate the 75th percentile threshold
WITH volume_threshold AS (
    SELECT 
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_patients) as threshold
    FROM (
        SELECT 
            npi,
            SUM(patient_count) as total_patients
        FROM mimi_ws_1.provdatacatalog.dac_ec_public_reporting
        WHERE patient_count IS NOT NULL
        GROUP BY npi
    )
),

-- Calculate provider-level metrics
provider_volume AS (
    SELECT 
        pr.npi,
        pr.provider_last_name,
        pr.provider_first_name,
        COUNT(DISTINCT pr.measure_cd) as measure_count,
        SUM(pr.patient_count) as total_patient_count,
        AVG(CAST(pr.star_value AS FLOAT)) as avg_star_rating,
        CASE 
            WHEN SUM(pr.patient_count) > (SELECT threshold FROM volume_threshold)
            THEN 'High Volume' 
            ELSE 'Standard Volume' 
        END as volume_category
    FROM mimi_ws_1.provdatacatalog.dac_ec_public_reporting pr
    WHERE pr.patient_count IS NOT NULL 
    AND pr.star_value IS NOT NULL
    GROUP BY pr.npi, pr.provider_last_name, pr.provider_first_name
)

SELECT 
    volume_category,
    COUNT(DISTINCT npi) as provider_count,
    ROUND(AVG(total_patient_count), 0) as avg_patient_volume,
    ROUND(AVG(avg_star_rating), 2) as avg_star_rating,
    ROUND(MIN(avg_star_rating), 2) as min_star_rating,
    ROUND(MAX(avg_star_rating), 2) as max_star_rating
FROM provider_volume
GROUP BY volume_category
ORDER BY volume_category;

-- How it works:
-- 1. Creates a CTE to calculate the 75th percentile threshold separately
-- 2. Creates a second CTE to aggregate provider-level metrics
-- 3. Categorizes providers based on pre-calculated threshold
-- 4. Summarizes key metrics by volume category

-- Assumptions:
-- 1. Patient_count represents meaningful volume metric
-- 2. Star ratings are comparable across different measures
-- 3. Null values in patient_count or star_value should be excluded
-- 4. 75th percentile is appropriate threshold for high volume designation

-- Limitations:
-- 1. Does not account for measure complexity or specialty differences
-- 2. Time period variations not considered
-- 3. Does not address potential data quality issues
-- 4. May not capture all relevant quality indicators

-- Possible Extensions:
-- 1. Add specialty-specific analysis
-- 2. Include temporal trends analysis
-- 3. Add geographic segmentation
-- 4. Incorporate measure complexity weighting
-- 5. Add statistical significance testing
-- 6. Include cost/efficiency metrics
-- 7. Add peer group comparisons
-- 8. Develop provider scorecard view

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:25:37.596905
    - Additional Notes: This query segments providers into volume categories based on the 75th percentile threshold of patient counts and analyzes their quality metrics through star ratings. The results show the distribution of providers across volume categories and their corresponding quality performance metrics. Query performance may be impacted with very large datasets due to multiple aggregations.
    
    */