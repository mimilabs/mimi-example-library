-- medicare_high_risk_medication_elderly.sql

-- Business Purpose: Analyze prescribing patterns of medications considered high-risk for elderly patients
-- This analysis helps:
-- 1. Identify providers frequently prescribing potentially inappropriate medications for seniors
-- 2. Support medication safety initiatives and quality improvement programs
-- 3. Enable targeted provider education about safer therapeutic alternatives

WITH high_risk_meds AS (
  -- List of commonly identified high-risk medications for elderly
  -- Based on American Geriatrics Society Beers Criteria
  SELECT gnrc_name FROM (VALUES
    ('diphenhydramine'),
    ('amitriptyline'),
    ('cyclobenzaprine'),
    ('promethazine'),
    ('carisoprodol'),
    ('diazepam'),
    ('zolpidem'),
    ('megestrol')
  ) AS meds(gnrc_name)
),

provider_metrics AS (
  -- Calculate key metrics for providers prescribing high-risk medications
  SELECT 
    p.prscrbr_npi,
    p.prscrbr_last_org_name,
    p.prscrbr_first_name,
    p.prscrbr_state_abrvtn,
    p.prscrbr_type,
    COUNT(DISTINCT p.gnrc_name) as num_high_risk_drugs,
    SUM(p.tot_clms) as total_high_risk_claims,
    SUM(p.ge65_tot_clms) as elderly_claims,
    SUM(p.tot_drug_cst) as total_cost,
    SUM(p.tot_benes) as total_patients
  FROM mimi_ws_1.datacmsgov.mupdpr p
  INNER JOIN high_risk_meds h 
    ON LOWER(p.gnrc_name) = h.gnrc_name
  WHERE p.mimi_src_file_date = '2022-12-31'
    AND p.ge65_tot_clms IS NOT NULL
  GROUP BY 1,2,3,4,5
)

SELECT 
  prscrbr_type,
  prscrbr_state_abrvtn,
  COUNT(DISTINCT prscrbr_npi) as num_providers,
  AVG(num_high_risk_drugs) as avg_high_risk_drugs_per_provider,
  SUM(elderly_claims) as total_elderly_claims,
  ROUND(SUM(total_cost)/SUM(elderly_claims),2) as avg_cost_per_claim,
  SUM(total_patients) as total_patients_affected
FROM provider_metrics
GROUP BY 1,2
HAVING num_providers >= 10
ORDER BY total_elderly_claims DESC
LIMIT 20;

-- How it works:
-- 1. Creates a reference list of high-risk medications based on Beers Criteria
-- 2. Joins prescription data with high-risk medication list
-- 3. Calculates provider-level metrics for high-risk prescribing
-- 4. Aggregates results by provider specialty and state
-- 5. Filters to ensure statistical significance and privacy

-- Assumptions and Limitations:
-- 1. List of high-risk medications is not exhaustive
-- 2. Analysis doesn't account for clinical circumstances that might justify use
-- 3. Suppressed claims (less than 11) are excluded
-- 4. Limited to one year of data
-- 5. Doesn't consider dosage or duration of therapy

-- Possible Extensions:
-- 1. Add trending analysis across multiple years
-- 2. Include therapeutic alternatives analysis
-- 3. Add risk-adjusted metrics based on patient population
-- 4. Develop provider peer comparison metrics
-- 5. Include geographic hot-spot analysis at county level

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:29:40.220119
    - Additional Notes: Query focuses on Medicare Part D providers prescribing medications that are potentially inappropriate for elderly patients based on Beers Criteria. The analysis is limited to a predefined set of high-risk medications and requires careful interpretation as some prescriptions may be clinically appropriate in specific cases. Results are aggregated at state and specialty level to protect patient privacy and ensure statistical significance.
    
    */