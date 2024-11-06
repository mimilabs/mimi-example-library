-- Title: Housing Market Analysis - Average Rental Rate Distribution by State Over Time

-- Business Purpose:
-- This analysis helps understand the rental market landscape at the state level,
-- identifying states with consistently high, medium and low rental rates.
-- Key business applications include:
-- - Market segmentation and targeting for real estate investment
-- - Understanding geographic rental price disparities
-- - Supporting state-level policy and investment decisions
-- - Baseline for more detailed regional analysis

WITH state_metrics AS (
    -- Calculate key rental metrics for each state and date
    SELECT 
        state_name,
        date,
        ROUND(AVG(value), 2) as avg_rent,
        ROUND(MIN(value), 2) as min_rent,
        ROUND(MAX(value), 2) as max_rent,
        COUNT(DISTINCT zip) as zip_count
    FROM mimi_ws_1.zillow.rent_zip
    WHERE state_name IS NOT NULL 
        AND value > 0
    GROUP BY state_name, date
),

latest_period AS (
    -- Get the most recent date in the dataset
    SELECT MAX(date) as max_date
    FROM state_metrics
)

-- Final output with rental rate classifications
SELECT 
    sm.state_name,
    sm.date,
    sm.avg_rent,
    sm.min_rent,
    sm.max_rent,
    sm.zip_count,
    CASE 
        WHEN sm.avg_rent > p75.percentile_75 THEN 'High'
        WHEN sm.avg_rent > p25.percentile_25 THEN 'Medium'
        ELSE 'Low'
    END as rental_tier
FROM state_metrics sm
CROSS JOIN (
    -- Calculate 75th percentile of average rents
    SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_rent) as percentile_75
    FROM state_metrics
    WHERE date = (SELECT max_date FROM latest_period)
) p75
CROSS JOIN (
    -- Calculate 25th percentile of average rents
    SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY avg_rent) as percentile_25
    FROM state_metrics
    WHERE date = (SELECT max_date FROM latest_period)
) p25
WHERE sm.date = (SELECT max_date FROM latest_period)
ORDER BY sm.avg_rent DESC;

-- How it works:
-- 1. Calculates average, min, and max rental rates by state and date
-- 2. Identifies the most recent period in the dataset
-- 3. Computes 25th and 75th percentiles for rental rate classification
-- 4. Classifies states into high/medium/low rental tiers
-- 5. Returns final results for the most recent period

-- Assumptions and Limitations:
-- - Assumes data quality and completeness across states
-- - Uses simple averages without weighting by population or housing stock
-- - Classification thresholds (25th/75th percentiles) are relative to current data
-- - Limited to ZIP codes covered by Zillow data
-- - Doesn't account for variations in housing quality or local market conditions

-- Possible Extensions:
-- 1. Add year-over-year growth rates for each state
-- 2. Include population-weighted averages
-- 3. Add seasonal adjustment factors
-- 4. Compare state metrics to national averages
-- 5. Include counts of different property types (SFH vs MFH)
-- 6. Add economic indicators (e.g., median income) for correlation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:56:35.515816
    - Additional Notes: Query provides state-level rental market segmentation using percentile-based classification. Note that results are most meaningful when analyzing the latest available data period, and classifications are relative rather than absolute thresholds.
    
    */