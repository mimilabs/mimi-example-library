-- Title: High Growth ZIP Code Identification for Real Estate Investment
-- Business Purpose: 
-- This analysis helps identify ZIP codes with the strongest rental price growth momentum,
-- supporting real estate investment decisions, market expansion strategies, and portfolio optimization.
-- Key applications include:
-- - Investment targeting for property acquisitions
-- - Market selection for rental property development
-- - Risk assessment for existing real estate portfolios
-- - Competitive market analysis for property management companies

WITH YearlyRentals AS (
    -- Calculate year-over-year rental growth by ZIP code
    SELECT 
        zip,
        state_name,
        city,
        YEAR(date) as year,
        AVG(value) as avg_rent,
        LAG(AVG(value)) OVER (PARTITION BY zip ORDER BY YEAR(date)) as prev_year_rent
    FROM mimi_ws_1.zillow.rent_zip
    WHERE date >= '2020-01-01'  -- Focus on recent years
    GROUP BY zip, state_name, city, YEAR(date)
),

GrowthMetrics AS (
    -- Calculate growth rates and rankings
    SELECT 
        zip,
        state_name,
        city,
        year,
        avg_rent,
        prev_year_rent,
        ((avg_rent - prev_year_rent) / prev_year_rent * 100) as yoy_growth
    FROM YearlyRentals
    WHERE prev_year_rent IS NOT NULL
)

SELECT 
    zip,
    state_name,
    city,
    year,
    ROUND(avg_rent, 2) as average_rent,
    ROUND(yoy_growth, 1) as growth_percentage,
    RANK() OVER (PARTITION BY year ORDER BY yoy_growth DESC) as growth_rank
FROM GrowthMetrics
WHERE year = 2023  -- Focus on most recent year
AND avg_rent > 1500  -- Filter for markets with substantial rental rates
ORDER BY growth_percentage DESC
LIMIT 25;

-- How it works:
-- 1. First CTE calculates yearly average rents by ZIP code
-- 2. Second CTE computes year-over-year growth rates
-- 3. Final query ranks ZIP codes by growth rate and filters for relevant markets
-- 4. Results show top 25 growth markets with their metrics

-- Assumptions and Limitations:
-- - Assumes current year data is complete and representative
-- - Only considers ZIP codes with continuous data for year-over-year comparison
-- - Growth rates alone may not indicate market stability or investment quality
-- - Minimum rent threshold of $1500 may need adjustment for different markets

-- Possible Extensions:
-- 1. Add trailing 3-year growth rates for longer-term trend analysis
-- 2. Include population or employment data for market size context
-- 3. Add volatility metrics to assess market stability
-- 4. Compare growth rates against metro area averages
-- 5. Include seasonality analysis for more nuanced market understanding
-- 6. Add additional filters for market size or demographic characteristics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:01:50.260110
    - Additional Notes: Query focuses on high-value markets with strong rental growth. $1500 rent threshold and 2023 focus year should be adjusted based on specific market analysis needs. Missing data in recent periods may affect growth calculations.
    
    */