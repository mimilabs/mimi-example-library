-- Title: Medicare Beneficiary Service Complexity and Multiple Diagnoses Analysis

-- Business Purpose:
-- This query analyzes the diagnostic complexity of Medicare beneficiaries by examining:
-- - Number of distinct diagnoses per claim
-- - Claims with multiple diagnoses vs single diagnosis
-- - Volume of claims per beneficiary
-- This helps identify high-complexity patients and understand care patterns for resource planning.

WITH diagnosis_counts AS (
  SELECT 
    bene_id,
    clm_id,
    -- Count distinct non-null diagnosis codes per claim
    (CASE WHEN prncpal_dgns_cd IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN icd_dgns_cd1 IS NOT NULL AND icd_dgns_cd1 != prncpal_dgns_cd THEN 1 ELSE 0 END +
     CASE WHEN icd_dgns_cd2 IS NOT NULL AND icd_dgns_cd2 NOT IN (prncpal_dgns_cd, icd_dgns_cd1) THEN 1 ELSE 0 END +
     CASE WHEN icd_dgns_cd3 IS NOT NULL AND icd_dgns_cd3 NOT IN (prncpal_dgns_cd, icd_dgns_cd1, icd_dgns_cd2) THEN 1 ELSE 0 END
    ) as distinct_diagnosis_count,
    clm_pmt_amt
  FROM mimi_ws_1.synmedpuf.carrier
  WHERE clm_from_dt >= '2020-01-01'
)

SELECT
  -- Segment claims by diagnostic complexity
  CASE 
    WHEN distinct_diagnosis_count >= 3 THEN 'High Complexity (3+ diagnoses)'
    WHEN distinct_diagnosis_count = 2 THEN 'Medium Complexity (2 diagnoses)'
    ELSE 'Low Complexity (1 diagnosis)'
  END as complexity_segment,
  
  -- Calculate key metrics
  COUNT(DISTINCT bene_id) as unique_beneficiaries,
  COUNT(DISTINCT clm_id) as total_claims,
  COUNT(DISTINCT clm_id) * 100.0 / SUM(COUNT(DISTINCT clm_id)) OVER () as claim_percentage,
  AVG(distinct_diagnosis_count) as avg_diagnoses_per_claim,
  AVG(clm_pmt_amt) as avg_payment_amount,
  
  -- Calculate claims per beneficiary
  COUNT(DISTINCT clm_id) * 1.0 / COUNT(DISTINCT bene_id) as claims_per_beneficiary

FROM diagnosis_counts
GROUP BY 
  CASE 
    WHEN distinct_diagnosis_count >= 3 THEN 'High Complexity (3+ diagnoses)'
    WHEN distinct_diagnosis_count = 2 THEN 'Medium Complexity (2 diagnoses)'
    ELSE 'Low Complexity (1 diagnosis)'
  END
ORDER BY claim_percentage DESC;

-- How it works:
-- 1. Creates a CTE to count distinct diagnoses per claim while avoiding duplicates
-- 2. Segments claims into complexity tiers based on diagnosis count
-- 3. Calculates key metrics for each complexity segment
-- 4. Provides insights into relationship between diagnostic complexity and utilization

-- Assumptions and Limitations:
-- - Only considers first 4 diagnosis codes for simplicity
-- - Assumes diagnosis codes are properly populated
-- - Limited to claims from 2020 onwards
-- - Does not account for diagnosis severity/type
-- - Synthetic data may not perfectly reflect real diagnostic patterns

-- Possible Extensions:
-- 1. Add temporal analysis to track complexity trends over time
-- 2. Include provider specialty analysis within complexity segments
-- 3. Analyze geographic variations in diagnostic complexity
-- 4. Incorporate diagnosis groupings or hierarchies
-- 5. Add payment analysis by complexity tier
-- 6. Link to other claims tables for complete patient complexity view

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:07:54.623221
    - Additional Notes: Query focuses on per-beneficiary complexity analysis using diagnosis counts as a proxy for patient care complexity. Limited to first 4 diagnosis codes and 2020+ data. Useful for care management and resource allocation planning but should be combined with other metrics for complete risk assessment.
    
    */