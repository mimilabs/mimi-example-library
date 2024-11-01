-- Healthcare Access Analysis by Urban-Rural Classification
-- 
-- Business Purpose:
-- Analyze the urban-rural classification patterns to identify areas that may need
-- targeted healthcare resource allocation and access improvement strategies.
-- This analysis helps healthcare organizations and policymakers understand where
-- to focus their efforts in improving healthcare access.

WITH classification_counts AS (
    -- Get the count of counties by classification type
    SELECT 
        '2013' as year,
        CASE `2013_code`
            WHEN 1 THEN 'Large central metro'
            WHEN 2 THEN 'Large fringe metro'
            WHEN 3 THEN 'Medium metro'
            WHEN 4 THEN 'Small metro'
            WHEN 5 THEN 'Micropolitan'
            WHEN 6 THEN 'Noncore'
        END as classification,
        COUNT(*) as county_count,
        SUM(county_2012_pop) as total_population
    FROM mimi_ws_1.cdc.urbanrural_classification
    GROUP BY `2013_code`
),
population_metrics AS (
    -- Calculate population statistics for each classification
    SELECT 
        classification,
        county_count,
        total_population,
        ROUND(total_population / county_count, 0) as avg_population_per_county,
        ROUND(100.0 * total_population / SUM(total_population) OVER (), 1) as population_percentage
    FROM classification_counts
)

-- Final output with key metrics for healthcare access planning
SELECT 
    classification,
    county_count,
    FORMAT_NUMBER(total_population, 0) as total_population,
    FORMAT_NUMBER(avg_population_per_county, 0) as avg_population_per_county,
    CONCAT(population_percentage, '%') as population_percentage
FROM population_metrics
ORDER BY 
    -- Order from most urban to most rural
    CASE classification
        WHEN 'Large central metro' THEN 1
        WHEN 'Large fringe metro' THEN 2
        WHEN 'Medium metro' THEN 3
        WHEN 'Small metro' THEN 4
        WHEN 'Micropolitan' THEN 5
        WHEN 'Noncore' THEN 6
    END;

-- How this query works:
-- 1. Creates a CTE to count counties and sum population by classification
-- 2. Calculates key metrics including average population and percentages
-- 3. Formats the output for easy interpretation
--
-- Assumptions:
-- - 2013 classification is most relevant for current analysis
-- - Population data from 2012 is representative for classification analysis
-- - All counties have valid population data
--
-- Limitations:
-- - Does not account for geographic distribution within states
-- - Does not consider changes in classification over time
-- - Population data may be outdated for current planning
--
-- Possible Extensions:
-- 1. Add state-level grouping to identify regional patterns
-- 2. Include temporal analysis comparing 1990, 2006, and 2013 classifications
-- 3. Cross-reference with healthcare facility data to analyze access gaps
-- 4. Add distance to nearest major medical center analysis
-- 5. Include demographic factors for more detailed access analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:16:58.450880
    - Additional Notes: Query calculates key population and distribution metrics across urban-rural classifications to support healthcare resource planning. The metrics include county counts, total population, average population per county, and population percentage distribution across different regional classifications. Note that the analysis uses 2012-2013 data which may need updating for current planning purposes.
    
    */