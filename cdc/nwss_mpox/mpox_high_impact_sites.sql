-- File: mpox_high_impact_sites_analysis.sql
-- Title: Identification of High-Impact Mpox Monitoring Sites
--
-- Business Purpose:
-- Identify and prioritize wastewater monitoring sites that have the highest potential
-- impact for public health monitoring based on population coverage and detection history.
-- This helps optimize resource allocation and strengthen surveillance networks.

WITH site_metrics AS (
    -- Calculate key metrics for each monitoring site
    SELECT 
        key_plot_id,
        fullgeoname,
        population_served,
        COUNT(DISTINCT sample_collect_date) as sample_count,
        SUM(pos_samples) as total_positives,
        AVG(percent_detections) as avg_detection_rate,
        MAX(sample_collect_date) as last_sample_date
    FROM mimi_ws_1.cdc.nwss_mpox
    WHERE sample_collect_date >= DATE_SUB(CURRENT_DATE(), 90)
    GROUP BY key_plot_id, fullgeoname, population_served
),

ranked_sites AS (
    -- Score and rank sites based on impact potential
    SELECT 
        *,
        CASE 
            WHEN population_served IS NULL THEN 0
            ELSE population_served 
        END * sample_count * avg_detection_rate as impact_score
    FROM site_metrics
    WHERE population_served > 0
      AND sample_count >= 5  -- Minimum samples for reliability
)

SELECT 
    fullgeoname as state,
    key_plot_id,
    ROUND(population_served, 0) as population_covered,
    sample_count as samples_last_90days,
    ROUND(avg_detection_rate, 2) as avg_detection_pct,
    ROUND(impact_score/1000000, 2) as impact_score_millions,
    last_sample_date
FROM ranked_sites
WHERE impact_score > 0
ORDER BY impact_score DESC
LIMIT 20;

-- How this works:
-- 1. First CTE calculates key metrics for each monitoring site over the last 90 days
-- 2. Second CTE creates an impact score based on population, sampling frequency, and detection rates
-- 3. Final query presents the top 20 highest-impact sites with normalized metrics
--
-- Assumptions and limitations:
-- - Sites must have at least 5 samples in the last 90 days
-- - Population served must be greater than 0
-- - Impact score may be biased towards larger population centers
-- - Doesn't account for geographic distribution or redundancy
--
-- Possible extensions:
-- - Add geographic clustering analysis to ensure balanced coverage
-- - Include trend analysis to identify sites with increasing detection rates
-- - Compare impact scores across different data sources
-- - Add cost-effectiveness metrics if sampling cost data becomes available
-- - Create tiered categories for different levels of surveillance priority

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:06:49.595482
    - Additional Notes: Query weights population coverage, sampling frequency, and detection rates to identify the most strategically important monitoring sites. Impact score calculation may need adjustment based on specific public health priorities. Consider regional population density variations when interpreting results.
    
    */