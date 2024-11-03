-- biologics_market_trends_by_bla_type.sql

-- Business Purpose: 
-- Analyze the growth and market dynamics of different types of biological products
-- by examining approval trends across BLA types over time. This helps:
-- 1. Identify emerging categories of biological products
-- 2. Track market evolution and maturity
-- 3. Support strategic planning for manufacturers and investors

WITH yearly_approvals AS (
    SELECT 
        YEAR(approval_date) as approval_year,
        bla_type,
        COUNT(*) as products_approved,
        COUNT(DISTINCT applicant) as unique_manufacturers
    FROM mimi_ws_1.fda.purplebook
    WHERE approval_date IS NOT NULL 
    AND YEAR(approval_date) >= 2018  -- Focus on recent 5 years
    GROUP BY approval_year, bla_type
),

growth_calc AS (
    SELECT 
        approval_year,
        bla_type,
        products_approved,
        unique_manufacturers,
        products_approved - LAG(products_approved) OVER (
            PARTITION BY bla_type 
            ORDER BY approval_year
        ) as yoy_growth
    FROM yearly_approvals
)

SELECT 
    approval_year,
    bla_type,
    products_approved,
    unique_manufacturers,
    yoy_growth,
    ROUND(100.0 * yoy_growth / NULLIF(products_approved - yoy_growth, 0), 1) as growth_percentage
FROM growth_calc
WHERE approval_year > 2018  -- Exclude first year where YoY growth is null
ORDER BY approval_year DESC, products_approved DESC;

-- How it works:
-- 1. Creates yearly summaries of approvals by BLA type
-- 2. Calculates year-over-year growth in approvals
-- 3. Computes key metrics including unique manufacturers and growth rates
-- 4. Presents results in a clear, actionable format

-- Assumptions & Limitations:
-- 1. Focuses on last 5 years of data for relevance
-- 2. Requires valid approval dates
-- 3. Growth calculations start from 2019 to ensure full year comparisons
-- 4. Assumes BLA types are consistently categorized over time

-- Possible Extensions:
-- 1. Add market concentration analysis (HHI index by BLA type)
-- 2. Include route of administration breakdown within BLA types
-- 3. Incorporate exclusivity expiration analysis for market opportunity assessment
-- 4. Add seasonal patterns analysis within years
-- 5. Compare approval success rates across BLA types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:16:51.195647
    - Additional Notes: Query focuses on year-over-year trends in biologics approvals with emphasis on BLA types and manufacturer diversity. Growth calculations start from 2019 to ensure meaningful year-over-year comparisons. Results are most relevant for strategic planning and market analysis purposes.
    
    */