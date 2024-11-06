-- CBSA Principal City Strategic Influence Analysis
--
-- Business Purpose:
-- Identify CBSAs where the principal city has a different name from the CBSA title,
-- suggesting potential regional influence and brand recognition opportunities.
-- This helps organizations understand where local branding may need to differ
-- from regional market positioning.

WITH standardized_names AS (
    -- Standardize names by removing common suffixes and converting to uppercase
    SELECT
        cbsa_code,
        cbsa_title,
        metropolitan_micropolitan_statistical_area,
        principal_city_name,
        UPPER(REGEXP_REPLACE(cbsa_title, '(-[^-]+)$', '')) as clean_cbsa_title,
        UPPER(principal_city_name) as clean_city_name
    FROM mimi_ws_1.census.cbsa_to_principal_city_fips
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.census.cbsa_to_principal_city_fips)
),

name_match_analysis AS (
    -- Compare CBSA names with principal city names
    SELECT 
        cbsa_code,
        cbsa_title,
        metropolitan_micropolitan_statistical_area,
        principal_city_name,
        CASE 
            WHEN clean_city_name IN (SELECT REGEXP_EXTRACT(clean_cbsa_title, '[^-]+'))
            THEN 'City name in CBSA title'
            ELSE 'Different naming'
        END as naming_pattern
    FROM standardized_names
)

-- Final result showing strategic naming patterns
SELECT 
    naming_pattern,
    metropolitan_micropolitan_statistical_area,
    COUNT(*) as area_count,
    COUNT(DISTINCT cbsa_code) as unique_cbsas,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentage
FROM name_match_analysis
GROUP BY naming_pattern, metropolitan_micropolitan_statistical_area
ORDER BY metropolitan_micropolitan_statistical_area, naming_pattern;

-- How this query works:
-- 1. First CTE standardizes names by removing suffixes and standardizing case
-- 2. Second CTE analyzes if principal city names appear in CBSA titles
-- 3. Final query aggregates results to show patterns in naming conventions
--
-- Assumptions and limitations:
-- - Assumes current naming conventions in the most recent data
-- - May not capture complex multi-city CBSA names
-- - Simple string matching might miss some nuanced name relationships
--
-- Possible extensions:
-- 1. Add population data to weight the analysis by market size
-- 2. Include historical analysis to show how naming patterns changed
-- 3. Add geographic region analysis to show regional naming patterns
-- 4. Incorporate additional demographic or economic indicators
-- 5. Create market penetration strategies based on naming patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:31:14.781973
    - Additional Notes: This query focuses on analyzing naming relationships between CBSAs and their principal cities, which can be valuable for regional marketing strategies and brand positioning. Note that the string matching logic is basic and may need refinement for special cases like hyphenated city names or multi-word place names.
    
    */