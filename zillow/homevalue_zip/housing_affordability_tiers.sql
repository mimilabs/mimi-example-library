-- zip_code_affordability_analysis.sql

-- Business Purpose:
-- Analyze home affordability across different zip codes and regions to:
-- 1. Help potential homebuyers identify affordable areas
-- 2. Assist real estate developers in market opportunity assessment
-- 3. Support policy makers in understanding housing affordability challenges
-- 4. Guide financial institutions in mortgage product development

WITH current_values AS (
    -- Get the most recent home values for each zip code
    SELECT 
        zip,
        state,
        city,
        metro,
        value as current_value,
        DATE_TRUNC('month', date) as month_date
    FROM mimi_ws_1.zillow.homevalue_zip
    WHERE date = (SELECT MAX(date) FROM mimi_ws_1.zillow.homevalue_zip)
),

price_tiers AS (
    -- Calculate price tiers based on current values
    SELECT 
        PERCENTILE_CONT(0.33) WITHIN GROUP (ORDER BY current_value) as low_tier,
        PERCENTILE_CONT(0.66) WITHIN GROUP (ORDER BY current_value) as high_tier
    FROM current_values
),

categorized_values AS (
    -- Categorize locations into affordability tiers
    SELECT 
        cv.state,
        cv.metro,
        cv.city,
        cv.zip,
        cv.current_value,
        CASE 
            WHEN cv.current_value <= (SELECT low_tier FROM price_tiers) THEN 'Affordable'
            WHEN cv.current_value <= (SELECT high_tier FROM price_tiers) THEN 'Moderate'
            ELSE 'Premium'
        END as affordability_tier
    FROM current_values cv
    WHERE cv.current_value IS NOT NULL
)

-- Final analysis combining metrics
SELECT 
    cv.*,
    COUNT(*) OVER (PARTITION BY cv.state, cv.affordability_tier) as locations_in_tier,
    ROUND(AVG(cv.current_value) OVER (PARTITION BY cv.state), 0) as state_avg_value
FROM categorized_values cv
ORDER BY cv.state, cv.current_value DESC;

-- How it works:
-- 1. Creates a CTE for most recent home values
-- 2. Calculates price tiers using percentiles
-- 3. Creates a CTE that categorizes locations into affordability tiers
-- 4. Provides state-level context for comparison

-- Assumptions and Limitations:
-- 1. Uses current values only, not historical trends
-- 2. Assumes national percentiles for affordability tiers
-- 3. Does not account for local income levels
-- 4. Missing values are excluded from analysis

-- Possible Extensions:
-- 1. Add year-over-year price changes
-- 2. Include local income data for affordability ratios
-- 3. Add population density correlation
-- 4. Compare to rental market data
-- 5. Add seasonal adjustment factors

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:14:00.233324
    - Additional Notes: The query segments housing markets into three price tiers (Affordable, Moderate, Premium) based on the 33rd and 66th percentiles of current home values. It provides state-level aggregations and counts of properties in each tier, useful for identifying affordable housing markets and understanding price distributions across different regions.
    
    */