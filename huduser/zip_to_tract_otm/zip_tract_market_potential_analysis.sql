-- zip_tract_demographic_market_potential.sql
-- ================================================
-- Business Purpose:
-- Analyze market potential and demographic concentration by identifying
-- ZIP codes with diverse residential distribution across Census tracts,
-- enabling targeted marketing and strategic business planning

WITH demographic_concentration AS (
    SELECT 
        zip,
        usps_zip_pref_city,
        usps_zip_pref_state,
        COUNT(DISTINCT tract) AS unique_tracts,
        AVG(res_ratio) AS avg_residential_ratio,
        MAX(res_ratio) AS max_residential_ratio,
        SUM(CASE WHEN res_ratio >= 0.5 THEN 1 ELSE 0 END) AS high_density_tract_count
    FROM mimi_ws_1.huduser.zip_to_tract_otm
    GROUP BY zip, usps_zip_pref_city, usps_zip_pref_state
),
market_potential_ranking AS (
    SELECT 
        *,
        NTILE(5) OVER (ORDER BY unique_tracts DESC) AS tract_diversity_quintile,
        NTILE(5) OVER (ORDER BY avg_residential_ratio DESC) AS residential_concentration_quintile
    FROM demographic_concentration
)

SELECT 
    zip,
    usps_zip_pref_city,
    usps_zip_pref_state,
    unique_tracts,
    avg_residential_ratio,
    max_residential_ratio,
    high_density_tract_count,
    tract_diversity_quintile,
    residential_concentration_quintile,
    CASE 
        WHEN tract_diversity_quintile >= 4 AND residential_concentration_quintile >= 4 
        THEN 'High Potential Market'
        WHEN tract_diversity_quintile >= 3 AND residential_concentration_quintile >= 3 
        THEN 'Moderate Potential Market'
        ELSE 'Lower Potential Market'
    END AS market_potential_segment
FROM market_potential_ranking
ORDER BY unique_tracts DESC, avg_residential_ratio DESC
LIMIT 500;

-- Query Mechanics:
-- 1. Aggregates ZIP code level demographic distribution information
-- 2. Calculates tract diversity and residential concentration metrics
-- 3. Creates market potential segments based on quintile rankings

-- Assumptions:
-- - Higher tract diversity suggests more complex demographic landscape
-- - Multiple high-density tracts indicate varied residential patterns
-- - Quintile rankings provide relative market segmentation

-- Possible Extensions:
-- 1. Incorporate additional demographic data sources
-- 2. Add business/commercial ratio analysis
-- 3. Create geospatial visualizations of market potential
-- 4. Develop predictive models for market expansion strategies

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:42:25.573380
    - Additional Notes: Query uses quintile ranking to segment ZIP codes by tract diversity and residential concentration, providing a framework for targeted market strategy development. Requires further validation with additional demographic datasets for comprehensive insights.
    
    */