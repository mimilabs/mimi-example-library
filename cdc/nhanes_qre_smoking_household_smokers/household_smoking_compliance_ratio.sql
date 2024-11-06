-- Title: Smoking Intensity Correlation with Home Smoking Rules

-- Business Purpose:
-- This analysis examines the relationship between the number of smokers in a household
-- and their smoking behavior inside the home. The insights help:
-- 1. Evaluate the effectiveness of home smoking policies
-- 2. Identify patterns of indoor smoking despite having multiple smokers
-- 3. Support public health interventions targeting household smoking behaviors

WITH household_patterns AS (
    SELECT 
        -- Count households in each category
        COUNT(*) as household_count,
        
        -- Total smokers in household
        smd460 as total_smokers,
        
        -- Indoor smokers
        smd470 as indoor_smokers,
        
        -- Calculate ratio of indoor to total smokers
        CASE 
            WHEN smd460 > 0 THEN ROUND(CAST(smd470 AS FLOAT) / smd460, 2)
            ELSE 0 
        END as indoor_smoking_ratio,
        
        -- Categorize smoking frequency
        CASE 
            WHEN smd480 = 0 THEN 'No indoor smoking'
            WHEN smd480 BETWEEN 1 AND 3 THEN 'Occasional (1-3 days)'
            WHEN smd480 BETWEEN 4 AND 6 THEN 'Frequent (4-6 days)'
            WHEN smd480 = 7 THEN 'Daily'
            ELSE 'Unknown'
        END as indoor_smoking_frequency
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers
    WHERE smd460 IS NOT NULL
    GROUP BY smd460, smd470, smd480
)

SELECT 
    total_smokers,
    indoor_smokers,
    indoor_smoking_ratio,
    indoor_smoking_frequency,
    household_count,
    ROUND(100.0 * household_count / SUM(household_count) OVER(), 1) as pct_of_total
FROM household_patterns
WHERE total_smokers > 0
ORDER BY total_smokers, indoor_smokers;

-- How this query works:
-- 1. Creates a CTE to aggregate household smoking patterns
-- 2. Calculates ratio of indoor smokers to total smokers
-- 3. Categorizes frequency of indoor smoking
-- 4. Produces final summary with percentages

-- Assumptions and Limitations:
-- 1. Assumes survey responses are accurate and representative
-- 2. Does not account for seasonal variations in smoking behavior
-- 3. Cannot distinguish between different types of tobacco products
-- 4. Missing values are excluded from analysis

-- Possible Extensions:
-- 1. Add temporal analysis using mimi_src_file_date
-- 2. Include specific tobacco product analysis (cigarettes vs cigars)
-- 3. Cross-reference with number of cigarettes (smd430) for intensity analysis
-- 4. Add geographic analysis if location data becomes available
-- 5. Compare patterns between different survey periods

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:28:46.231189
    - Additional Notes: Query introduces a novel ratio-based approach to measure compliance with indoor smoking restrictions. The indoor_smoking_ratio metric provides a normalized measure of how many household smokers continue to smoke indoors, making it useful for comparing behaviors across households of different sizes. Consider that zero values in denominators are handled through CASE statements, which may need adjustment based on specific analytical needs.
    
    */