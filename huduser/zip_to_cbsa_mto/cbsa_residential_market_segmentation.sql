-- zip_cbsa_residential_market_segmentation.sql
-- 
-- Business Purpose:
-- Analyze residential market diversity and concentration across Core-Based Statistical Areas (CBSAs)
-- Provide insights into geographic market segmentation for strategic planning, 
-- real estate investment, and demographic research by examining residential distribution patterns

WITH residential_market_stats AS (
    -- Calculate key residential metrics for each CBSA
    SELECT 
        cbsa,
        usps_zip_pref_state,
        COUNT(DISTINCT zip) AS total_zip_codes,
        COUNT(DISTINCT CASE WHEN res_ratio > 0.5 THEN zip END) AS dominant_residential_zips,
        ROUND(AVG(res_ratio), 3) AS avg_residential_ratio,
        ROUND(STDDEV(res_ratio), 3) AS res_ratio_variation,
        COUNT(DISTINCT usps_zip_pref_city) AS unique_cities,
        MIN(score) AS min_mapping_confidence,
        MAX(score) AS max_mapping_confidence
    FROM mimi_ws_1.huduser.zip_to_cbsa_mto
    WHERE cbsa != '99999'  -- Exclude non-CBSA areas
    GROUP BY cbsa, usps_zip_pref_state
),
market_concentration_ranking AS (
    -- Rank CBSAs by residential market complexity and diversity
    SELECT 
        cbsa,
        usps_zip_pref_state,
        total_zip_codes,
        avg_residential_ratio,
        res_ratio_variation,
        unique_cities,
        min_mapping_confidence,
        PERCENT_RANK() OVER (ORDER BY total_zip_codes) AS zip_code_distribution_percentile,
        PERCENT_RANK() OVER (ORDER BY unique_cities) AS city_diversity_percentile
    FROM residential_market_stats
)

-- Final output with strategic market segmentation insights
SELECT 
    cbsa,
    usps_zip_pref_state,
    total_zip_codes,
    avg_residential_ratio,
    res_ratio_variation,
    unique_cities,
    zip_code_distribution_percentile,
    city_diversity_percentile,
    CASE 
        WHEN total_zip_codes > 10 AND unique_cities > 5 THEN 'Complex Market'
        WHEN total_zip_codes BETWEEN 5 AND 10 THEN 'Moderate Market'
        ELSE 'Simple Market'
    END AS market_complexity_category
FROM market_concentration_ranking
ORDER BY total_zip_codes DESC, city_diversity_percentile DESC
LIMIT 100;

-- Query Execution Details:
-- 1. Aggregates ZIP code data at the CBSA level
-- 2. Calculates residential distribution metrics
-- 3. Ranks CBSAs by market complexity
-- 4. Provides strategic market segmentation insights

-- Assumptions and Limitations:
-- - Uses residential ratio as primary market characterization metric
-- - Excludes CBSAs without geographic designation
-- - Snapshot represents mapping as of March 20, 2024

-- Potential Extensions:
-- 1. Incorporate economic data to enhance market insights
-- 2. Add temporal analysis of CBSA market changes
-- 3. Integrate with additional demographic datasets
-- 4. Create predictive models for market potential

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:10:53.304887
    - Additional Notes: Provides comprehensive analysis of residential market characteristics across Core-Based Statistical Areas, using multiple metrics to segment and rank geographic markets. Requires careful interpretation of results and understanding of the underlying ZIP code to CBSA mapping methodology.
    
    */