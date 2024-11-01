-- Title: Medicare Provider Specialty Service Pattern Analysis

-- Business Purpose:
-- This query analyzes the distribution of services across different provider specialties
-- to understand referral patterns and concentration of care delivery.
-- Key insights include:
-- - Which provider specialties are handling the most claims
-- - Geographic distribution of specialties
-- - Most common services by specialty
-- This helps inform network adequacy and care access planning.

WITH specialty_summary AS (
  -- Aggregate claims by provider specialty and location
  SELECT 
    prvdr_spclty,
    prvdr_state_cd,
    COUNT(DISTINCT clm_id) as claim_count,
    COUNT(DISTINCT bene_id) as unique_patients,
    COUNT(DISTINCT hcpcs_cd) as unique_services,
    ROUND(AVG(line_srvc_cnt),2) as avg_services_per_claim,
    COUNT(DISTINCT prvdr_zip) as unique_locations
  FROM mimi_ws_1.synmedpuf.carrier
  WHERE prvdr_spclty IS NOT NULL
  GROUP BY prvdr_spclty, prvdr_state_cd
),

ranked_specialties AS (
  -- Rank specialties by volume within each state
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY prvdr_state_cd 
                       ORDER BY claim_count DESC) as state_rank
  FROM specialty_summary
)

-- Final output showing top specialties by state
SELECT 
  prvdr_state_cd as state,
  prvdr_spclty as specialty,
  claim_count,
  unique_patients,
  unique_services,
  avg_services_per_claim,
  unique_locations
FROM ranked_specialties
WHERE state_rank <= 5
ORDER BY prvdr_state_cd, claim_count DESC;

-- How this query works:
-- 1. First CTE aggregates key metrics by provider specialty and state
-- 2. Second CTE ranks specialties within each state by claim volume
-- 3. Final select filters to top 5 specialties per state
-- 4. Results show the distribution of care delivery across specialties and geography

-- Assumptions and Limitations:
-- - Provider specialty codes are accurately reported
-- - Analysis is at claim level, not accounting for claim line items
-- - Geographic analysis uses provider location, not patient location
-- - Synthetic data may not perfectly reflect real-world patterns

-- Possible Extensions:
-- 1. Add temporal analysis to see how patterns change over time
-- 2. Include diagnosis codes to understand condition-specific patterns
-- 3. Add payment analysis to understand cost variations by specialty
-- 4. Cross-reference with quality metrics when available
-- 5. Add drill-down capability for specific HCPCS codes
-- 6. Analyze referral patterns between specialties

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:17:14.172245
    - Additional Notes: Analyzes provider specialty patterns across states using Medicare carrier claims data. Query focuses on volume-based metrics (claims, patients, services) rather than financial aspects. Best used for network adequacy analysis and understanding regional variations in specialty care delivery. Performance may be impacted with very large datasets due to multiple window functions.
    
    */