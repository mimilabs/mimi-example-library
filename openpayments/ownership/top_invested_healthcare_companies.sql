-- top_10_invested_companies_by_year.sql

-- Business Purpose: Analyze the top companies receiving physician investments and track their trends over time.
-- This helps identify key industry players attracting significant physician capital, which is valuable for:
-- - Market intelligence on emerging healthcare companies
-- - Understanding physician investment preferences
-- - Monitoring industry consolidation patterns
-- - Compliance monitoring for unusual investment concentrations

WITH company_investments AS (
    -- Aggregate investments by company and year
    SELECT 
        program_year,
        submitting_applicable_manufacturer_or_applicable_gpo_name as company_name,
        COUNT(DISTINCT physician_profile_id) as unique_physicians,
        SUM(total_amount_invested_us_dollars) as total_investment,
        SUM(value_of_interest) as total_value,
        AVG(value_of_interest) as avg_value_per_physician
    FROM mimi_ws_1.openpayments.ownership
    WHERE total_amount_invested_us_dollars > 0
    GROUP BY 1, 2
),

ranked_companies AS (
    -- Rank companies by total investment within each year
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY program_year 
                          ORDER BY total_investment DESC) as rank
    FROM company_investments
)

-- Select top 10 companies for each year
SELECT 
    program_year,
    rank,
    company_name,
    unique_physicians,
    total_investment,
    total_value,
    avg_value_per_physician,
    ROUND(total_investment/NULLIF(unique_physicians,0), 2) as avg_investment_per_physician
FROM ranked_companies
WHERE rank <= 10
ORDER BY program_year DESC, rank ASC;

-- How it works:
-- 1. First CTE aggregates investment data by company and year
-- 2. Second CTE ranks companies based on total investment amount
-- 3. Final query filters for top 10 and calculates relevant metrics

-- Assumptions:
-- - Focuses on positive investment amounts only
-- - Companies are identified by their submitted names (may need standardization)
-- - Values are reported accurately in the source data

-- Limitations:
-- - Does not account for company name variations or subsidiaries
-- - Cannot track companies that changed names between years
-- - Does not consider company size or market capitalization

-- Possible Extensions:
-- 1. Add year-over-year growth calculations
-- 2. Include company industry/sector classification
-- 3. Add investment concentration metrics (e.g., HHI)
-- 4. Compare private vs public company investments
-- 5. Add time series analysis for trend detection

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:59:14.748297
    - Additional Notes: Query tracks investment concentration in healthcare companies over time. Note that company names may need standardization due to variations in reporting. Performance may be impacted with large datasets due to window functions and multiple aggregations.
    
    */