-- Provider Referral Specialty Market Concentration Analysis
--
-- Business Purpose:
-- This analysis identifies specialties with high concentrations of referral authority
-- to help healthcare organizations:
-- - Target high-value specialist partnerships 
-- - Understand service line referral patterns
-- - Guide strategy for specialist network development
-- - Support value-based care initiatives

WITH provider_referral_counts AS (
  -- Calculate total referral types per provider
  SELECT 
    npi,
    last_name,
    first_name,
    (CASE WHEN partb = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN dme = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN hha = 'Y' THEN 1 ELSE 0 END + 
     CASE WHEN pmd = 'Y' THEN 1 ELSE 0 END +
     CASE WHEN hospice = 'Y' THEN 1 ELSE 0 END) as total_referral_types
  FROM mimi_ws_1.datacmsgov.orderandreferring
  WHERE _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.orderandreferring)
),

referral_segments AS (
  -- Segment providers by referral breadth
  SELECT
    CASE 
      WHEN total_referral_types = 5 THEN 'Full-Spectrum'
      WHEN total_referral_types >= 3 THEN 'Multi-Service'
      WHEN total_referral_types = 2 THEN 'Dual-Service'
      ELSE 'Single-Service'
    END as referral_segment,
    COUNT(*) as provider_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as segment_percentage
  FROM provider_referral_counts
  GROUP BY 
    CASE 
      WHEN total_referral_types = 5 THEN 'Full-Spectrum'
      WHEN total_referral_types >= 3 THEN 'Multi-Service'
      WHEN total_referral_types = 2 THEN 'Dual-Service'
      ELSE 'Single-Service'
    END
)

-- Final output with market concentration metrics
SELECT
  referral_segment,
  provider_count,
  segment_percentage as market_share_pct,
  ROUND(segment_percentage / 100.0, 4) as market_share_decimal,
  ROUND(POW(segment_percentage / 100.0, 2) * 100, 2) as herfindahl_component
FROM referral_segments
ORDER BY provider_count DESC;

-- How this works:
-- 1. First CTE calculates total referral authorities per provider
-- 2. Second CTE segments providers into meaningful business categories
-- 3. Final query presents market concentration metrics
--
-- Assumptions & Limitations:
-- - Uses most recent data snapshot only
-- - Treats all referral types as equally important
-- - Doesn't consider geographic distribution
-- - Assumes Y/N indicators are clean and consistent
--
-- Possible Extensions:
-- 1. Add temporal trending of concentration metrics
-- 2. Include geographic stratification
-- 3. Weight different referral types by business value
-- 4. Add provider name analysis for duplicates/variations
-- 5. Calculate additional market concentration metrics (e.g., CR4, Gini)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:15:15.483203
    - Additional Notes: This query provides market concentration metrics for Medicare referral authority patterns. Note that the Herfindahl component calculation included in the output can be used as part of a full Herfindahl-Hirschman Index (HHI) calculation for deeper market concentration analysis. The segmentation approach using Full-Spectrum to Single-Service categories provides actionable business intelligence for network development.
    
    */