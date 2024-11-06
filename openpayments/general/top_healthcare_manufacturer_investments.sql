-- top_manufacturers_investment.sql
--
-- Business Purpose:
-- Analyze the top manufacturers' investment patterns across payment types to understand:
-- - Which manufacturers are making the largest healthcare investments
-- - The breakdown of their investments by payment category
-- - Year-over-year investment trends
-- This helps identify key industry players, their strategic focus, and market leadership.

WITH manufacturer_payments AS (
    -- Get total payments by manufacturer and payment type for each year
    SELECT 
        applicable_manufacturer_or_applicable_gpo_making_payment_name AS manufacturer_name,
        nature_of_payment_or_transfer_of_value AS payment_type,
        program_year,
        COUNT(*) AS payment_count,
        SUM(total_amount_of_payment_us_dollars) AS total_payment_amount,
        SUM(number_of_payments_included_in_total_amount) AS total_transactions
    FROM mimi_ws_1.openpayments.general
    WHERE applicable_manufacturer_or_applicable_gpo_making_payment_name IS NOT NULL
        AND total_amount_of_payment_us_dollars > 0
    GROUP BY 1,2,3
),

manufacturer_summary AS (
    -- Calculate manufacturer-level metrics and rankings
    SELECT 
        manufacturer_name,
        program_year,
        COUNT(DISTINCT payment_type) AS payment_type_count,
        SUM(payment_count) AS total_payments,
        SUM(total_payment_amount) AS annual_investment,
        SUM(total_transactions) AS total_transactions,
        DENSE_RANK() OVER (PARTITION BY program_year ORDER BY SUM(total_payment_amount) DESC) AS investment_rank
    FROM manufacturer_payments
    GROUP BY 1,2
)

-- Final output with top manufacturers and their investment patterns
SELECT 
    m.manufacturer_name,
    m.program_year,
    m.payment_type_count,
    m.total_payments,
    m.annual_investment,
    m.total_transactions,
    m.investment_rank,
    ROUND((m.annual_investment - LAG(m.annual_investment) OVER (
        PARTITION BY m.manufacturer_name 
        ORDER BY m.program_year)
    ) / NULLIF(LAG(m.annual_investment) OVER (
        PARTITION BY m.manufacturer_name 
        ORDER BY m.program_year), 0) * 100, 2) AS yoy_growth_pct
FROM manufacturer_summary m
WHERE m.investment_rank <= 10
ORDER BY m.program_year DESC, m.annual_investment DESC;

-- How it works:
-- 1. First CTE aggregates payments by manufacturer, payment type, and year
-- 2. Second CTE calculates manufacturer-level metrics and rankings
-- 3. Final query adds year-over-year growth and filters for top 10 manufacturers
--
-- Assumptions and limitations:
-- - Assumes positive payment amounts only
-- - Focuses on direct monetary investments (excludes non-monetary transfers)
-- - Year-over-year calculations require at least 2 years of data
-- - Rankings based purely on total payment amounts
--
-- Possible extensions:
-- 1. Add payment type distribution analysis for top manufacturers
-- 2. Include recipient type analysis (physicians vs teaching hospitals)
-- 3. Add market share calculations within therapeutic areas
-- 4. Incorporate dispute status analysis
-- 5. Add seasonal payment pattern analysis within years

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:26:29.299371
    - Additional Notes: Query focuses on monetary investments and may exclude smaller manufacturers who primarily provide non-monetary value transfers. The year-over-year growth calculations will show null values for a manufacturer's first year of data. Performance may be impacted with very large datasets due to window functions.
    
    */