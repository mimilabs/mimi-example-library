-- snf_referral_patterns.sql

-- Business Purpose:
-- Analyze referral patterns and admission sources for Skilled Nursing Facility (SNF) claims
-- to understand patient flow and care coordination between facilities.
-- This insight helps optimize network relationships and improve care transitions.

WITH admission_sources AS (
  -- Get distribution of admission sources and categorize them
  SELECT 
    clm_src_ip_admsn_cd,
    COUNT(*) as admission_count,
    COUNT(DISTINCT bene_id) as unique_patients,
    ROUND(AVG(clm_pmt_amt), 2) as avg_payment,
    ROUND(AVG(DATEDIFF(clm_thru_dt, clm_from_dt)), 1) as avg_los
  FROM mimi_ws_1.synmedpuf.snf
  WHERE clm_src_ip_admsn_cd IS NOT NULL
  GROUP BY clm_src_ip_admsn_cd
),

referring_providers AS (
  -- Get top referring providers/facilities 
  SELECT
    prvdr_num,
    prvdr_state_cd,
    COUNT(DISTINCT bene_id) as patients_referred,
    COUNT(*) as total_referrals,
    ROUND(AVG(clm_pmt_amt), 2) as avg_payment_per_claim
  FROM mimi_ws_1.synmedpuf.snf
  WHERE prvdr_num IS NOT NULL
  GROUP BY prvdr_num, prvdr_state_cd
)

-- Combine results into final summary
SELECT
  'Admission Sources' as metric_type,
  a.clm_src_ip_admsn_cd as category,
  a.admission_count as count,
  a.unique_patients,
  a.avg_payment,
  a.avg_los
FROM admission_sources a
WHERE a.admission_count > 10

UNION ALL

SELECT
  'Top Referring Providers' as metric_type,
  r.prvdr_state_cd as category,
  r.total_referrals as count,
  r.patients_referred as unique_patients,
  r.avg_payment_per_claim as avg_payment,
  NULL as avg_los
FROM referring_providers r
WHERE r.total_referrals > 10
ORDER BY metric_type, count DESC;

-- How it works:
-- 1. First CTE analyzes admission source codes to understand where patients are coming from
-- 2. Second CTE looks at referring provider patterns
-- 3. Final query combines both views with key metrics per category
-- 4. Filters applied to focus on statistically significant patterns (>10 claims)

-- Assumptions and Limitations:
-- - Requires valid admission source codes and provider numbers
-- - Limited to fee-for-service Medicare claims
-- - Does not account for seasonal variations
-- - Geographic analysis limited to state level

-- Possible Extensions:
-- 1. Add temporal analysis to identify referral pattern changes over time
-- 2. Include diagnosis codes to analyze clinical specialty patterns
-- 3. Expand geographic analysis to more granular levels
-- 4. Add quality metrics for referring providers
-- 5. Calculate readmission rates by referral source

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:57:08.964777
    - Additional Notes: Query focuses on understanding patient flow into SNF facilities by analyzing both admission sources and referring provider patterns. The minimum threshold of 10 claims may need adjustment based on data volume. State-level aggregation provides a good starting point but may mask important regional variations.
    
    */