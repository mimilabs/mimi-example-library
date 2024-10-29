-- Hospital Network Control Type Analysis and Market Consolidation Trends
-- Business Purpose: Analyze trends in hospital ownership/control patterns to understand:
-- - Market consolidation through changes in control type over time
-- - Geographic distribution of different hospital ownership models
-- - Provider network relationships and potential M&A opportunities
-- This analysis supports strategic planning, market assessment, and competitive intelligence

WITH provider_annual_status AS (
  -- Get the most recent report for each provider per fiscal year
  SELECT 
    DISTINCT
    prvdr_num,
    prvdr_ctrl_type_cd,
    EXTRACT(YEAR FROM fy_bgn_dt) as report_year,
    -- Look at key dates to understand reporting patterns
    fy_bgn_dt,
    fy_end_dt,
    fi_rcpt_dt
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_rpt
  WHERE rpt_stus_cd = '1' -- Focus on settled cost reports
    AND EXTRACT(YEAR FROM fy_bgn_dt) BETWEEN 2018 AND 2022 -- Recent 5 year trend
),

control_type_trends AS (
  -- Analyze changes in control type over time
  SELECT
    report_year,
    prvdr_ctrl_type_cd,
    COUNT(DISTINCT prvdr_num) as provider_count,
    COUNT(DISTINCT prvdr_num) * 100.0 / SUM(COUNT(DISTINCT prvdr_num)) OVER (PARTITION BY report_year) as pct_of_total
  FROM provider_annual_status
  GROUP BY report_year, prvdr_ctrl_type_cd
)

SELECT
  report_year,
  prvdr_ctrl_type_cd,
  provider_count,
  ROUND(pct_of_total, 2) as market_share_pct,
  -- Calculate year-over-year change
  provider_count - LAG(provider_count) OVER (PARTITION BY prvdr_ctrl_type_cd ORDER BY report_year) as yoy_change,
  ROUND(pct_of_total - LAG(pct_of_total) OVER (PARTITION BY prvdr_ctrl_type_cd ORDER BY report_year), 2) as market_share_change
FROM control_type_trends
ORDER BY report_year, provider_count DESC;

-- How this query works:
-- 1. Creates base provider status table with one record per provider per year
-- 2. Aggregates to show control type distribution and trends
-- 3. Calculates market share and year-over-year changes

-- Assumptions & Limitations:
-- - Uses settled cost reports only (status code 1)
-- - Limited to recent 5 year period
-- - Assumes control type changes represent actual ownership changes vs reporting differences
-- - Does not account for system affiliations without ownership changes

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Include bed size or revenue tiers for size-based segmentation
-- 3. Identify providers with control type changes for detailed M&A analysis
-- 4. Add financial metrics to understand performance by ownership type
-- 5. Create predictive model for likely ownership changes/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:05:25.443634
    - Additional Notes: This analysis focuses on provider control type changes over 5 years (2018-2022) using settled cost reports only. The query helps identify market consolidation patterns and shifts in hospital ownership models. Control type codes should be cross-referenced with CMS documentation for proper interpretation. Results are most meaningful when analyzed alongside regulatory filings and known M&A activities.
    
    */