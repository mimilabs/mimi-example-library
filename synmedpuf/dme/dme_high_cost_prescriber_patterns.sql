-- DME Claims Analysis - High Cost Equipment Prescriber Patterns
--
-- Business Purpose:
--   Analyze Medicare DME claims to understand prescriber patterns for high-cost equipment:
--   - Identify key referring physicians ordering expensive DME
--   - Track volume and total costs of high-value DME orders
--   - Support efforts to optimize DME prescription patterns and cost management
--   - Flag potential outliers in DME prescribing behavior

WITH high_cost_dme AS (
  -- Identify DME claims above $1000 allowed charge
  SELECT 
    rfr_physn_npi,
    hcpcs_cd,
    COUNT(DISTINCT clm_id) as claim_count,
    COUNT(DISTINCT bene_id) as patient_count,
    SUM(line_alowd_chrg_amt) as total_allowed_amt,
    AVG(line_alowd_chrg_amt) as avg_allowed_amt
  FROM mimi_ws_1.synmedpuf.dme
  WHERE line_alowd_chrg_amt > 1000
  AND rfr_physn_npi IS NOT NULL
  GROUP BY rfr_physn_npi, hcpcs_cd
  HAVING COUNT(DISTINCT clm_id) >= 5
)

SELECT
  rfr_physn_npi as prescriber_npi,
  hcpcs_cd as equipment_code,
  claim_count,
  patient_count,
  total_allowed_amt,
  avg_allowed_amt,
  -- Calculate metrics for pattern analysis
  ROUND(patient_count/claim_count, 2) as patients_per_claim,
  ROUND(total_allowed_amt/patient_count, 2) as cost_per_patient
FROM high_cost_dme
ORDER BY total_allowed_amt DESC
LIMIT 100;

-- How this query works:
-- 1. CTE identifies DME claims with allowed charges > $1000
-- 2. Groups by referring physician NPI and HCPCS code
-- 3. Calculates key metrics like claim counts and costs
-- 4. Filters for providers with at least 5 claims to focus on regular prescribers
-- 5. Orders results by total allowed amount to highlight highest cost impact

-- Assumptions and Limitations:
-- - Relies on accurate NPI recording for referring physicians
-- - $1000 threshold is arbitrary and may need adjustment
-- - Does not account for medical necessity or appropriateness
-- - Limited to providers with 5+ claims which may miss occasional prescribers

-- Possible Extensions:
-- 1. Add provider specialty information to understand prescribing patterns by specialty
-- 2. Include diagnosis codes to analyze medical necessity patterns
-- 3. Compare against peer group averages to identify outliers
-- 4. Add temporal analysis to track changes in prescribing patterns
-- 5. Link to specific equipment types/categories for deeper analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:14:15.044356
    - Additional Notes: The $1000 threshold and minimum 5 claims filter should be adjusted based on specific analysis needs. Query focuses on referring physician patterns rather than DME suppliers themselves. Performance may be impacted with very large datasets due to the allowed charge aggregations.
    
    */