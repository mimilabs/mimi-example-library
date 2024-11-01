-- provider_contact_availability.sql
-- Business Purpose: Analyze provider contact information availability and completeness
-- to identify gaps in provider accessibility and communication readiness.
-- This helps ensure patients and other providers can reliably reach healthcare providers
-- and supports care coordination efforts.

WITH contact_status AS (
  -- Calculate contact method availability per provider
  SELECT 
    npi,
    COUNT(DISTINCT system) as num_contact_methods,
    MAX(CASE WHEN system = 'phone' THEN 1 ELSE 0 END) as has_phone,
    MAX(CASE WHEN system = 'fax' THEN 1 ELSE 0 END) as has_fax,
    MAX(CASE WHEN system = 'email' THEN 1 ELSE 0 END) as has_email,
    MAX(CASE WHEN period_end IS NOT NULL THEN 1 ELSE 0 END) as has_expired_contact
  FROM mimi_ws_1.nppes.fhir_telecom
  GROUP BY npi
)

-- Generate summary statistics and identify providers needing attention
SELECT
  num_contact_methods,
  COUNT(*) as provider_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_total,
  SUM(has_phone) as count_with_phone,
  SUM(has_fax) as count_with_fax,
  SUM(has_email) as count_with_email,
  SUM(has_expired_contact) as count_with_expired
FROM contact_status
GROUP BY num_contact_methods
ORDER BY num_contact_methods;

-- How this query works:
-- 1. Creates a CTE that analyzes each provider's contact methods
-- 2. Aggregates providers by number of contact methods available
-- 3. Calculates key metrics about contact method availability
-- 4. Orders results by number of contact methods for easy interpretation

-- Assumptions and Limitations:
-- - Assumes current contact methods if period_end is NULL
-- - Does not validate the format/validity of contact information
-- - Does not consider provider type or specialty differences
-- - Treats all contact methods with equal importance

-- Possible Extensions:
-- 1. Add provider specialty analysis to identify specialty-specific gaps
-- 2. Include geographic analysis to find regional patterns
-- 3. Add contact method validation checks
-- 4. Create priority scores based on provider characteristics
-- 5. Add trending analysis to track improvements over time
-- 6. Include contact value format validation
-- 7. Add provider type segmentation (individual vs organization)
-- 8. Cross-reference with active provider status
-- 9. Add contact method recency analysis
-- 10. Include analysis of preferred contact methods

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:54:35.456589
    - Additional Notes: Query focuses on contact method availability metrics but does not validate the quality or accuracy of the contact information. Results may need to be combined with provider status data to ensure only active providers are analyzed.
    
    */