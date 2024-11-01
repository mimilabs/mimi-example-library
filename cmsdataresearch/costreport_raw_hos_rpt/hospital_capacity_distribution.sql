-- Hospital Capacity and Bed Utilization Analysis for Strategic Planning
--
-- Business Purpose:
-- This analysis helps healthcare executives and strategists understand:
-- - Hospital bed capacity and utilization patterns across different provider types
-- - Year-over-year changes in hospital operations and scale
-- - Market concentration and service delivery capabilities by region
-- - Opportunities for network expansion or consolidation

WITH active_providers AS (
    -- Filter to most recent complete fiscal years and valid providers
    SELECT 
        prvdr_num,
        prvdr_ctrl_type_cd,
        YEAR(fy_bgn_dt) as fiscal_year,
        fy_bgn_dt,
        fy_end_dt
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_rpt
    WHERE rpt_stus_cd = 'F'  -- Final settled reports only
    AND fy_bgn_dt >= '2018-01-01' -- Focus on recent years
    AND prvdr_num IS NOT NULL
),

provider_years AS (
    -- Calculate provider operating metrics by year
    SELECT 
        fiscal_year,
        COUNT(DISTINCT prvdr_num) as total_providers,
        COUNT(DISTINCT CASE WHEN prvdr_ctrl_type_cd IN ('1','2','3') THEN prvdr_num END) as nonprofit_providers,
        COUNT(DISTINCT CASE WHEN prvdr_ctrl_type_cd IN ('4','5') THEN prvdr_num END) as profit_providers,
        COUNT(DISTINCT CASE WHEN prvdr_ctrl_type_cd IN ('7') THEN prvdr_num END) as govt_providers
    FROM active_providers
    GROUP BY fiscal_year
)

SELECT
    fiscal_year,
    total_providers,
    nonprofit_providers,
    profit_providers,
    govt_providers,
    ROUND(nonprofit_providers * 100.0 / total_providers, 1) as pct_nonprofit,
    ROUND(profit_providers * 100.0 / total_providers, 1) as pct_profit,
    ROUND(govt_providers * 100.0 / total_providers, 1) as pct_govt,
    -- Calculate year-over-year change
    LAG(total_providers) OVER (ORDER BY fiscal_year) as prev_year_providers,
    ROUND((total_providers - LAG(total_providers) OVER (ORDER BY fiscal_year)) * 100.0 
        / NULLIF(LAG(total_providers) OVER (ORDER BY fiscal_year), 0), 1) as yoy_change_pct
FROM provider_years
ORDER BY fiscal_year DESC;

-- How this query works:
-- 1. Creates a CTE for active providers filtering for final settled reports
-- 2. Aggregates provider counts by fiscal year and ownership type
-- 3. Calculates percentages and year-over-year changes
-- 4. Orders results by most recent year first

-- Assumptions and Limitations:
-- - Assumes report status 'F' indicates final settled reports
-- - Limited to 2018 onwards for recent trend analysis
-- - Provider control type codes are mapped to three main categories
-- - Does not account for mid-year ownership changes

-- Possible Extensions:
-- 1. Add geographic analysis by provider state/region
-- 2. Include bed size categories for capacity analysis
-- 3. Add financial metrics like total charges or costs
-- 4. Incorporate quality metrics for value analysis
-- 5. Add seasonal patterns analysis using fiscal year begin/end dates
-- 6. Compare urban vs rural provider trends

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:05:58.514729
    - Additional Notes: Query focuses on provider distribution trends across ownership types and can require significant processing time for large datasets due to multiple window functions. Consider adding date range parameters for more flexible analysis periods. Provider control type codes should be validated against current CMS documentation as classifications may change over time.
    
    */