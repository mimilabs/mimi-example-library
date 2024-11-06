-- Title: Medicare Advantage Plan Contract Performance and Growth Trend Analysis

-- Business Purpose: Analyze enrollment trends and growth patterns for Medicare Advantage
-- contracts to identify successful plans and market dynamics. This helps health insurers
-- and investors understand which contracts are gaining/losing members and their 
-- geographic distribution for strategic planning and competitive analysis.

WITH contract_monthly_totals AS (
    -- Calculate total enrollment by contract and month
    SELECT 
        contract_number,
        DATE_TRUNC('month', mimi_src_file_date) as report_month,
        SUM(enrollment) as total_enrollment,
        COUNT(DISTINCT fips_state_county_code) as counties_served
    FROM mimi_ws_1.partcd.cpsc_enrollment
    GROUP BY 1, 2
),

contract_growth AS (
    -- Calculate month-over-month growth for each contract
    SELECT 
        contract_number,
        report_month,
        total_enrollment,
        counties_served,
        (total_enrollment - LAG(total_enrollment) OVER (
            PARTITION BY contract_number 
            ORDER BY report_month
        )) as monthly_member_change,
        ROUND(
            ((total_enrollment * 1.0) / NULLIF(LAG(total_enrollment) OVER (
                PARTITION BY contract_number 
                ORDER BY report_month
            ), 0) - 1) * 100,
            2
        ) as growth_rate_pct
    FROM contract_monthly_totals
)

SELECT 
    contract_number,
    report_month,
    total_enrollment,
    counties_served,
    monthly_member_change,
    growth_rate_pct,
    -- Calculate relative market position
    DENSE_RANK() OVER (
        PARTITION BY report_month 
        ORDER BY total_enrollment DESC
    ) as enrollment_rank
FROM contract_growth
WHERE report_month >= DATE_ADD(MONTHS, -12, (SELECT MAX(report_month) FROM contract_growth))
ORDER BY report_month DESC, total_enrollment DESC;

-- How it works:
-- 1. First CTE aggregates enrollment at the contract/month level
-- 2. Second CTE calculates growth metrics using window functions
-- 3. Final query adds ranking and filters to recent 12 months
-- 4. Results show enrollment trends, growth rates, and market position

-- Assumptions and Limitations:
-- - Assumes monthly data is complete and sequential
-- - Growth calculations may be affected by contract mergers/splits
-- - Does not account for plan benefit changes or premium differences
-- - Market ranking is based on total enrollment only

-- Possible Extensions:
-- 1. Add market share calculations within geographic regions
-- 2. Include parent organization groupings for corporate-level analysis
-- 3. Add seasonality adjustments for enrollment patterns
-- 4. Incorporate plan type and benefit package analysis
-- 5. Add demographic data to understand population characteristics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:00:49.051129
    - Additional Notes: Query focuses on month-over-month performance metrics for Medicare Advantage contracts and may require at least 13 months of historical data for proper growth calculations. Memory usage may be significant for large datasets due to multiple window function operations.
    
    */