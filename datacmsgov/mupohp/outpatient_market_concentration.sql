-- outpatient_service_concentration_analysis.sql

-- Business Purpose:
-- Analyzes market concentration of outpatient hospital services at the state level
-- Identifies states where a small number of providers handle large portions of services
-- Helps healthcare organizations and policymakers evaluate market dynamics and competition
-- Supports strategic planning for network adequacy and competitive positioning

WITH provider_state_totals AS (
    -- Calculate total services and payments by provider and state
    SELECT 
        rndrng_prvdr_state_abrvtn as state,
        rndrng_prvdr_ccn,
        rndrng_prvdr_org_name,
        SUM(capc_srvcs) as total_services,
        SUM(capc_srvcs * avg_mdcr_pymt_amt) as total_payments
    FROM mimi_ws_1.datacmsgov.mupohp
    WHERE mimi_src_file_date = '2022-12-31'
    GROUP BY 1,2,3
),

state_market_summary AS (
    -- Calculate market share metrics by state
    SELECT 
        state,
        COUNT(DISTINCT rndrng_prvdr_ccn) as provider_count,
        SUM(total_services) as state_total_services,
        SUM(total_payments) as state_total_payments,
        -- Calculate concentration ratios for top 5 providers
        SUM(CASE WHEN provider_rank <= 5 THEN total_services ELSE 0 END) / SUM(total_services) * 100 as top5_service_share,
        SUM(CASE WHEN provider_rank <= 5 THEN total_payments ELSE 0 END) / SUM(total_payments) * 100 as top5_payment_share
    FROM (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY state ORDER BY total_services DESC) as provider_rank
        FROM provider_state_totals
    )
    GROUP BY 1
)

-- Final output with market concentration insights
SELECT 
    state,
    provider_count,
    FORMAT_NUMBER(state_total_services, 0) as total_services,
    FORMAT_NUMBER(state_total_payments/1000000, 2) as total_payments_millions,
    FORMAT_NUMBER(top5_service_share, 1) as top5_providers_service_share_pct,
    FORMAT_NUMBER(top5_payment_share, 1) as top5_providers_payment_share_pct,
    FORMAT_NUMBER(state_total_services/provider_count, 0) as avg_services_per_provider,
    FORMAT_NUMBER(state_total_payments/provider_count/1000000, 2) as avg_payments_per_provider_millions
FROM state_market_summary
WHERE provider_count >= 5  -- Filter to states with meaningful provider counts
ORDER BY top5_service_share DESC;

-- How this query works:
-- 1. First CTE aggregates total services and payments by provider within each state
-- 2. Second CTE calculates market concentration metrics including top 5 provider shares
-- 3. Final select formats the results and adds derived metrics for analysis
-- 4. Results are ordered by market concentration (top 5 service share)

-- Assumptions and limitations:
-- - Analysis assumes 2022 data (adjust mimi_src_file_date as needed)
-- - Only includes Medicare outpatient services, not full market picture
-- - State-level analysis may mask local market dynamics
-- - Requires at least 5 providers per state for meaningful concentration analysis

-- Possible extensions:
-- 1. Add year-over-year comparison of market concentration
-- 2. Break down concentration by service type (APC)
-- 3. Add geographic submarket analysis (e.g., by RUCA codes)
-- 4. Calculate formal Herfindahl-Hirschman Index (HHI)
-- 5. Include provider ownership type in concentration analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:06:38.146627
    - Additional Notes: Query focuses on state-level market concentration metrics and requires at least 5 providers per state for meaningful analysis. The total payments calculations assume consistent payment rates across the measurement period and may need adjustment for payment policy changes.
    
    */