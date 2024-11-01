-- DME Claims Analysis - Service Type and Cost Distribution
-- Business Purpose: 
--   Analyze Medicare DME claims to understand:
--   - Most common types of DME services (using BETOS codes)
--   - Cost distribution across service types
--   - Comparative analysis of submitted vs allowed charges
--   This helps identify high-volume and high-cost DME service categories 
--   to inform procurement strategies and cost management initiatives.

WITH service_metrics AS (
  SELECT 
    betos_cd,
    COUNT(DISTINCT clm_id) AS claim_count,
    COUNT(DISTINCT bene_id) AS beneficiary_count,
    SUM(line_sbmtd_chrg_amt) AS total_submitted_amt,
    SUM(line_alowd_chrg_amt) AS total_allowed_amt,
    AVG(line_alowd_chrg_amt) AS avg_allowed_amt,
    SUM(line_srvc_cnt) AS total_service_units
  FROM mimi_ws_1.synmedpuf.dme
  WHERE betos_cd IS NOT NULL
  GROUP BY betos_cd
)

SELECT 
  betos_cd,
  claim_count,
  beneficiary_count,
  total_submitted_amt,
  total_allowed_amt,
  avg_allowed_amt,
  total_service_units,
  -- Calculate cost efficiency metrics
  ROUND((total_allowed_amt / NULLIF(total_submitted_amt, 0)) * 100, 2) AS allowed_to_submitted_pct,
  ROUND(total_allowed_amt / NULLIF(total_service_units, 0), 2) AS cost_per_service_unit
FROM service_metrics
ORDER BY total_allowed_amt DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to aggregate key metrics by BETOS service category
-- 2. Calculates volume metrics (claims, beneficiaries, service units)
-- 3. Computes financial metrics (submitted charges, allowed charges, averages)
-- 4. Derives efficiency metrics (allowed/submitted ratio, cost per unit)
-- 5. Orders results by total allowed amount to highlight highest-cost categories

-- Assumptions and Limitations:
-- - BETOS codes are present and valid
-- - Service units are comparable within BETOS categories
-- - Financial amounts are in the same currency unit
-- - Analysis is at point-in-time, not showing trends

-- Possible Extensions:
-- 1. Add time-based trending analysis by incorporating date fields
-- 2. Include provider specialty analysis to see which specialties drive DME costs
-- 3. Add geographical analysis by incorporating provider state
-- 4. Incorporate diagnosis codes to understand medical conditions driving DME use
-- 5. Add seasonality analysis to identify usage patterns throughout the year

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:20:14.551230
    - Additional Notes: Query provides service-level cost analysis of DME claims using BETOS codes as service categories. Best used for identifying cost patterns and service utilization trends across different DME types. Note that the effectiveness depends on the completeness of BETOS code mapping in the source data.
    
    */