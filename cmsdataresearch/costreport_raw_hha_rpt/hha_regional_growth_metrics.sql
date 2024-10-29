-- hha_costreport_geographic_expansion.sql
-- Business Purpose: Track regional growth patterns of Home Health Agencies to:
-- - Identify areas with increasing/decreasing HHA presence
-- - Monitor new market entries and exits
-- - Support market expansion strategy analysis
-- - Assess competitive landscape changes across regions

WITH yearly_provider_counts AS (
    -- Get distinct provider counts by state and year
    SELECT 
        YEAR(fy_bgn_dt) as fiscal_year,
        LEFT(prvdr_num, 2) as state_code,
        COUNT(DISTINCT prvdr_num) as active_providers,
        COUNT(DISTINCT CASE WHEN initl_rpt_sw = 'Y' THEN prvdr_num END) as new_providers
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_rpt
    WHERE fy_bgn_dt >= '2018-01-01'
    GROUP BY 1, 2
),

yoy_growth AS (
    -- Calculate year-over-year growth metrics
    SELECT 
        curr.fiscal_year,
        curr.state_code,
        curr.active_providers,
        curr.new_providers,
        curr.active_providers - prev.active_providers as provider_change,
        ROUND(100.0 * (curr.active_providers - prev.active_providers) / prev.active_providers, 1) as yoy_growth_pct
    FROM yearly_provider_counts curr
    LEFT JOIN yearly_provider_counts prev 
        ON curr.state_code = prev.state_code 
        AND curr.fiscal_year = prev.fiscal_year + 1
)

SELECT 
    fiscal_year,
    state_code,
    active_providers,
    new_providers,
    provider_change,
    yoy_growth_pct,
    CASE 
        WHEN yoy_growth_pct >= 5 THEN 'High Growth'
        WHEN yoy_growth_pct <= -5 THEN 'Declining'
        ELSE 'Stable'
    END as market_status
FROM yoy_growth
WHERE fiscal_year >= 2019  -- Exclude first year due to YoY calculation
ORDER BY fiscal_year DESC, active_providers DESC;

-- How it works:
-- 1. First CTE gets yearly provider counts by state
-- 2. Second CTE calculates year-over-year changes
-- 3. Final query adds market status classification and filters/sorts results

-- Assumptions & Limitations:
-- - Uses provider numbers for state identification (first 2 digits)
-- - New provider determination based on initial report flag
-- - Growth metrics may be affected by reporting delays or missing data
-- - Does not account for provider size/volume differences

-- Possible Extensions:
-- 1. Add provider control type dimension to track ownership expansion patterns
-- 2. Include metropolitan statistical area (MSA) analysis
-- 3. Add financial metrics to identify high-value markets
-- 4. Incorporate demographic data to assess market potential
-- 5. Create predictive model for market entry opportunities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:34:54.414144
    - Additional Notes: Query uses provider number prefix as state identifier which may need validation against a proper state mapping table. Growth calculations require at least two years of data, starting from 2018. Market status thresholds (±5%) are arbitrary and may need adjustment based on industry standards.
    
    */