-- Home Health Agency Growth and Profitability Analysis
-- Business Purpose: Analyzes new home health agency enrollments and profit status trends to:
-- 1. Track market expansion patterns in the home health industry
-- 2. Identify shifts between for-profit and non-profit business models
-- 3. Support market entry and investment decisions
-- 4. Guide policy and competitive strategy development

WITH quarterly_enrollments AS (
    -- Group enrollments by quarter to analyze growth trends
    SELECT 
        DATE_TRUNC('quarter', incorporation_date) as enrollment_quarter,
        proprietary_nonprofit,
        COUNT(DISTINCT enrollment_id) as new_agencies,
        COUNT(DISTINCT CASE WHEN multiple_npi_flag = 'Y' THEN enrollment_id END) as multi_location_agencies
    FROM mimi_ws_1.datacmsgov.pc_homehealth
    WHERE incorporation_date IS NOT NULL
    GROUP BY 1, 2
),
yoy_growth AS (
    -- Calculate year-over-year growth rates
    SELECT 
        enrollment_quarter,
        proprietary_nonprofit,
        new_agencies,
        multi_location_agencies,
        LAG(new_agencies, 4) OVER (PARTITION BY proprietary_nonprofit ORDER BY enrollment_quarter) as prev_year_agencies,
        CASE 
            WHEN LAG(new_agencies, 4) OVER (PARTITION BY proprietary_nonprofit ORDER BY enrollment_quarter) > 0 
            THEN (new_agencies - LAG(new_agencies, 4) OVER (PARTITION BY proprietary_nonprofit ORDER BY enrollment_quarter)) * 100.0 / 
                LAG(new_agencies, 4) OVER (PARTITION BY proprietary_nonprofit ORDER BY enrollment_quarter)
            ELSE NULL
        END as yoy_growth_rate
    FROM quarterly_enrollments
)

SELECT 
    enrollment_quarter,
    CASE proprietary_nonprofit
        WHEN 'P' THEN 'For-Profit'
        WHEN 'N' THEN 'Non-Profit'
        ELSE 'Unknown'
    END as business_model,
    new_agencies,
    multi_location_agencies,
    ROUND(multi_location_agencies * 100.0 / NULLIF(new_agencies, 0), 1) as multi_location_pct,
    ROUND(yoy_growth_rate, 1) as yoy_growth_rate_pct
FROM yoy_growth
WHERE enrollment_quarter >= DATE_ADD(YEAR, -5, CURRENT_DATE())
ORDER BY enrollment_quarter DESC, proprietary_nonprofit;

-- How it works:
-- 1. First CTE groups enrollments by quarter and profit status
-- 2. Second CTE calculates year-over-year growth rates using window functions
-- 3. Final query formats results and filters to last 5 years
-- 4. Includes metrics for multi-location agencies to indicate expansion patterns

-- Assumptions and Limitations:
-- 1. Incorporation date is used as proxy for market entry
-- 2. Missing incorporation dates are excluded
-- 3. Growth rates may be affected by data completeness
-- 4. Does not account for agencies that have closed

-- Possible Extensions:
-- 1. Add geographic dimension to analyze regional growth patterns
-- 2. Include organization type analysis for more detailed segmentation
-- 3. Correlate with demographic or economic indicators
-- 4. Add survival rate analysis for agencies over time
-- 5. Compare growth patterns with Medicare reimbursement rate changes/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:09:49.292875
    - Additional Notes: Query focuses on quarterly enrollment trends and profitability status of home health agencies. Growth rates may show significant variance in quarters with sparse data. For accurate trend analysis, consider pairing with agency closure data and adjusting the DATE_ADD lookback period based on data availability.
    
    */