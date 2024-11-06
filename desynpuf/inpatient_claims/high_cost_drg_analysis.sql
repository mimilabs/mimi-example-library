-- inpatient_high_cost_diagnosis_groups.sql

-- Business Purpose:
-- Analyzes high-cost inpatient diagnosis groups to identify opportunities for
-- targeted medical management programs and value-based care initiatives.
-- Key metrics include total spend, average cost per stay, and volume by DRG.
-- Used by Medical Directors and Care Management leaders for program development.

WITH claim_metrics AS (
  SELECT 
    clm_drg_cd,
    COUNT(DISTINCT clm_id) as total_stays,
    COUNT(DISTINCT desynpuf_id) as unique_patients,
    SUM(clm_pmt_amt) as total_paid,
    AVG(clm_pmt_amt) as avg_paid_per_stay,
    AVG(clm_utlztn_day_cnt) as avg_length_of_stay,
    -- Calculate readmission count within same DRG
    SUM(CASE WHEN EXISTS (
      SELECT 1 FROM mimi_ws_1.desynpuf.inpatient_claims b 
      WHERE a.desynpuf_id = b.desynpuf_id
      AND a.clm_drg_cd = b.clm_drg_cd
      AND b.clm_admsn_dt BETWEEN a.nch_bene_dschrg_dt 
      AND DATE_ADD(a.nch_bene_dschrg_dt, 30)
    ) THEN 1 ELSE 0 END) as readmit_count
  FROM mimi_ws_1.desynpuf.inpatient_claims a
  WHERE clm_drg_cd IS NOT NULL
  GROUP BY clm_drg_cd
)

SELECT
  clm_drg_cd as drg_code,
  total_stays,
  unique_patients,
  total_paid,
  avg_paid_per_stay,
  avg_length_of_stay,
  readmit_count,
  -- Calculate key ratios
  ROUND(readmit_count/total_stays * 100, 1) as readmit_rate,
  ROUND(total_paid/total_stays, 0) as cost_per_case,
  ROUND(total_stays/unique_patients, 2) as stays_per_patient
FROM claim_metrics
WHERE total_stays >= 100  -- Focus on high-volume DRGs
ORDER BY total_paid DESC
LIMIT 20;

-- How this works:
-- 1. Creates claim_metrics CTE to aggregate key metrics by DRG
-- 2. Identifies readmissions within same DRG using correlated subquery
-- 3. Calculates cost and utilization ratios
-- 4. Filters to high-volume DRGs and ranks by total spend

-- Assumptions & Limitations:
-- 1. DRG codes are consistently coded
-- 2. Payment amounts reflect total cost of care
-- 3. 30-day window used for readmission definition
-- 4. Minimum volume threshold of 100 stays
-- 5. Limited to same-DRG readmissions only

-- Possible Extensions:
-- 1. Add DRG descriptions and service line groupings
-- 2. Trend analysis over time periods
-- 3. Provider-level variation analysis
-- 4. Risk adjustment based on patient factors
-- 5. Comparison to expected costs/LOS by DRG
-- 6. Geographic variation analysis
-- 7. Expanded readmission definitions
-- 8. Integration with quality metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:43:27.081237
    - Additional Notes: Query focuses specifically on diagnosis-related groups (DRGs) with high total spend and volume (>=100 stays). The readmission logic only considers same-DRG readmissions, which may undercount total readmission rates. The 100-stay threshold may need adjustment based on population size.
    
    */