-- pac_rural_access_analysis.sql

-- Business Purpose:
-- Analyze access to post-acute care services in rural areas compared to urban areas
-- to identify potential gaps in care availability and inform policy decisions around
-- rural healthcare access. This analysis examines utilization patterns, service mix,
-- and payment differences between rural and urban beneficiary populations.

WITH provider_rural_metrics AS (
  -- Calculate key metrics aggregated by provider and rural status
  SELECT 
    srvc_ctgry,
    CASE WHEN bene_rrl_pct >= 50 THEN 'Rural' ELSE 'Urban' END as rural_status,
    COUNT(DISTINCT prvdr_id) as provider_count,
    SUM(bene_dstnct_cnt) as total_beneficiaries,
    AVG(bene_avg_risk_scre) as avg_risk_score,
    SUM(tot_mdcr_pymt_amt) / SUM(bene_dstnct_cnt) as payment_per_beneficiary,
    AVG(tot_srvc_days / NULLIF(bene_dstnct_cnt, 0)) as avg_los
  FROM mimi_ws_1.datacmsgov.muppac_geo
  WHERE smry_ctgry = 'Provider' 
  AND year = 2022
  AND prvdr_id IS NOT NULL
  GROUP BY 1, 2
)

SELECT
  srvc_ctgry,
  rural_status,
  provider_count,
  total_beneficiaries,
  ROUND(avg_risk_score, 2) as avg_risk_score,
  ROUND(payment_per_beneficiary, 0) as payment_per_beneficiary,
  ROUND(avg_los, 1) as avg_length_of_stay,
  -- Calculate relative metrics compared to urban areas
  ROUND(provider_count * 100.0 / 
    SUM(provider_count) OVER (PARTITION BY srvc_ctgry), 1) as pct_providers,
  ROUND(total_beneficiaries * 100.0 / 
    SUM(total_beneficiaries) OVER (PARTITION BY srvc_ctgry), 1) as pct_beneficiaries
FROM provider_rural_metrics
ORDER BY srvc_ctgry, rural_status DESC;

-- How the Query Works:
-- 1. Creates a CTE that aggregates key metrics by provider and rural status
-- 2. Classifies providers as rural if >50% of their beneficiaries are rural
-- 3. Calculates per-provider and per-beneficiary metrics
-- 4. Compares rural vs urban access using relative percentages
-- 5. Returns results organized by service category and rural status

-- Assumptions and Limitations:
-- - Uses 50% rural beneficiary threshold to classify providers
-- - Based on Medicare FFS claims only, excludes Medicare Advantage
-- - Rural/urban classification is based on beneficiary ZIP codes
-- - Provider location may differ from beneficiary rural status

-- Possible Extensions:
-- 1. Add state-level stratification to examine geographic variations
-- 2. Include quality metrics to compare outcomes
-- 3. Analyze trends over multiple years
-- 4. Add distance/drive time analysis for rural beneficiaries
-- 5. Examine specific service types within each PAC category
-- 6. Include demographic factors beyond rural status

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:09:57.015735
    - Additional Notes: Query assumes 50% rural beneficiary threshold for provider classification and requires 2022 data. Results are aggregated at the service category level comparing rural vs urban providers. Main metrics include provider counts, beneficiary volumes, risk scores, payments, and length of stay.
    
    */