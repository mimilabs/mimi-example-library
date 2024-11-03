-- Title: MEPS Service Type Trend Analysis by Variable Categories
-- Business Purpose:
-- Analyzes how healthcare service types and their descriptions have evolved over time
-- to identify shifting patterns in healthcare delivery and coding practices.
-- This helps healthcare organizations understand:
-- 1. Changes in service categorization and coding standards
-- 2. Evolution of healthcare delivery models
-- 3. Historical trends in healthcare service documentation

WITH yearly_var_counts AS (
    -- Get count of distinct variable names by category and year
    SELECT 
        year,
        category,
        COUNT(DISTINCT varname) as var_count,
        COUNT(DISTINCT value) as value_count
    FROM mimi_ws_1.ahrq.meps_event_label_dictionary
    WHERE category IS NOT NULL
    GROUP BY year, category
),

year_over_year AS (
    -- Calculate year-over-year changes
    SELECT 
        t1.year,
        t1.category,
        t1.var_count,
        t1.value_count,
        ROUND(((t1.var_count - LAG(t1.var_count) OVER (PARTITION BY t1.category ORDER BY t1.year)) * 100.0 / 
            NULLIF(LAG(t1.var_count) OVER (PARTITION BY t1.category ORDER BY t1.year), 0)), 2) as var_pct_change
    FROM yearly_var_counts t1
)

SELECT 
    year,
    category,
    var_count as variable_count,
    value_count as distinct_values,
    var_pct_change as variable_percent_change
FROM year_over_year
WHERE year >= 2018  -- Focus on recent years
ORDER BY year DESC, var_count DESC;

-- How this query works:
-- 1. First CTE aggregates counts of distinct variables and values by year and category
-- 2. Second CTE calculates year-over-year percentage changes
-- 3. Final output shows recent trends with key metrics

-- Assumptions and Limitations:
-- 1. Assumes category field is populated for relevant records
-- 2. Year-over-year changes may be affected by survey methodology changes
-- 3. Limited to available years in the dataset
-- 4. Focuses on structural changes rather than content changes

-- Possible Extensions:
-- 1. Add analysis of specific variable patterns within categories
-- 2. Include value description text analysis for terminology changes
-- 3. Compare patterns across different MEPS files
-- 4. Add seasonality analysis for variables that change within years
-- 5. Create forecasting model for expected future variable counts

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:20:28.426327
    - Additional Notes: Query focuses on structural changes in MEPS data collection over time, specifically tracking how variable and value counts change across categories. Best used for annual reporting and data governance reviews. May need adjustment of the year filter (2018) based on specific analysis needs.
    
    */