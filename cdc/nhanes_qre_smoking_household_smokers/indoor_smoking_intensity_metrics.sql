-- Title: Household Indoor Smoking Intensity Analysis
-- Business Purpose: 
-- This analysis quantifies the intensity of indoor smoking exposure by examining:
-- 1. Average number of cigarettes smoked inside homes
-- 2. Relationship between total household smokers and indoor smokers
-- 3. Distribution of multi-product tobacco use in homes
-- Value: Helps healthcare organizations target interventions and assess secondhand smoke risk

WITH smoking_metrics AS (
    SELECT 
        -- Count total valid responses
        COUNT(*) as total_households,
        
        -- Calculate average cigarettes smoked inside
        AVG(CASE WHEN smd430 BETWEEN 0 AND 100 THEN smd430 END) as avg_cigarettes_per_day,
        
        -- Compare total vs indoor smokers
        AVG(CASE WHEN smd460 BETWEEN 0 AND 20 THEN smd460 END) as avg_total_smokers,
        AVG(CASE WHEN smd470 BETWEEN 0 AND 20 THEN smd470 END) as avg_indoor_smokers,
        
        -- Analyze multi-product usage
        SUM(CASE 
            WHEN smd415a > 0 AND (smd415b > 0 OR smd415c > 0) THEN 1 
            ELSE 0 
        END) as multi_product_homes
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers)
),
indoor_smoking_frequency AS (
    SELECT 
        smd480 as days_smoked_last_week,
        COUNT(*) as household_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers
    WHERE smd480 BETWEEN 0 AND 7
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers)
    GROUP BY smd480
    ORDER BY smd480
)

SELECT 
    m.*,
    f.days_smoked_last_week,
    f.household_count,
    f.percentage as pct_households
FROM smoking_metrics m
CROSS JOIN indoor_smoking_frequency f;

-- How it works:
-- 1. First CTE calculates key smoking intensity metrics across households
-- 2. Second CTE analyzes the frequency of indoor smoking over the past week
-- 3. Main query combines these metrics for a comprehensive view

-- Assumptions and Limitations:
-- 1. Uses most recent survey data only (filtered by max mimi_src_file_date)
-- 2. Assumes valid ranges for numeric responses (filtered outliers)
-- 3. Does not account for seasonal variations in smoking patterns
-- 4. Self-reported data may underestimate actual smoking behavior

-- Possible Extensions:
-- 1. Add trend analysis across multiple survey periods
-- 2. Include geographic variation if location data available
-- 3. Correlate with respiratory health outcomes
-- 4. Segment analysis by household size or composition
-- 5. Calculate economic impact based on cigarette consumption

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:36:38.510256
    - Additional Notes: Query focuses on quantifying indoor tobacco exposure patterns through multiple metrics including average cigarette consumption, indoor vs total smoker ratios, and weekly smoking frequency. Best used with complete survey datasets as missing values in any key columns will affect aggregate calculations. The multi-product usage metric specifically tracks households using combinations of cigarettes with cigars or pipes.
    
    */