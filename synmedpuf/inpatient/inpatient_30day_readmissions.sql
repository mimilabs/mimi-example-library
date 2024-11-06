-- medicare_inpatient_readmissions.sql 

-- Business Purpose:
-- This analysis identifies potential readmissions patterns in Medicare inpatient claims
-- to help healthcare organizations:
-- 1. Monitor readmission rates and associated costs
-- 2. Identify patients at high risk for readmission
-- 3. Support quality improvement initiatives focused on reducing avoidable readmissions
-- 4. Optimize discharge planning and transitions of care

WITH patient_admissions AS (
  -- First get all admissions per patient ordered by date
  SELECT 
    bene_id,
    clm_id,
    clm_admsn_dt,
    clm_thru_dt,
    nch_bene_dschrg_dt,
    prncpal_dgns_cd,
    clm_pmt_amt,
    ptnt_dschrg_stus_cd
  FROM mimi_ws_1.synmedpuf.inpatient 
  WHERE clm_admsn_dt IS NOT NULL
),

readmissions AS (
  -- Identify subsequent admissions within 30 days of discharge
  SELECT 
    curr.bene_id,
    curr.clm_id as initial_stay_id,
    curr.clm_admsn_dt as initial_admission_date,
    curr.nch_bene_dschrg_dt as initial_discharge_date,
    curr.prncpal_dgns_cd as initial_diagnosis,
    curr.clm_pmt_amt as initial_payment,
    next.clm_id as readmission_stay_id,
    next.clm_admsn_dt as readmission_date,
    next.prncpal_dgns_cd as readmission_diagnosis,
    next.clm_pmt_amt as readmission_payment,
    DATEDIFF(next.clm_admsn_dt, curr.nch_bene_dschrg_dt) as days_to_readmission
  FROM patient_admissions curr
  INNER JOIN patient_admissions next 
    ON curr.bene_id = next.bene_id
    AND curr.nch_bene_dschrg_dt < next.clm_admsn_dt
    AND DATEDIFF(next.clm_admsn_dt, curr.nch_bene_dschrg_dt) <= 30
)

SELECT
  -- Calculate key readmission metrics
  COUNT(DISTINCT bene_id) as patients_with_readmissions,
  COUNT(*) as total_readmissions,
  ROUND(AVG(days_to_readmission),1) as avg_days_to_readmission,
  ROUND(AVG(readmission_payment),2) as avg_readmission_payment,
  ROUND(SUM(readmission_payment),2) as total_readmission_costs,
  
  -- Get readmission timing distribution
  COUNT(CASE WHEN days_to_readmission <= 7 THEN 1 END) as readmits_within_7_days,
  COUNT(CASE WHEN days_to_readmission BETWEEN 8 AND 14 THEN 1 END) as readmits_8_to_14_days,
  COUNT(CASE WHEN days_to_readmission BETWEEN 15 AND 30 THEN 1 END) as readmits_15_to_30_days

FROM readmissions;

-- How this query works:
-- 1. First CTE gets all admissions with valid admission dates
-- 2. Second CTE identifies readmissions by joining admissions table to itself
--    and finding subsequent stays within 30 days
-- 3. Main query calculates summary metrics about readmissions

-- Assumptions and limitations:
-- 1. Only considers readmissions within 30 days of discharge
-- 2. Treats all readmissions equally, regardless of diagnosis
-- 3. Does not exclude planned readmissions
-- 4. Limited to inpatient stays only (no ED or observation)
-- 5. Data is synthetic and for demonstration only

-- Possible extensions:
-- 1. Add diagnosis grouping to identify most common readmission conditions
-- 2. Calculate readmission rates by discharge disposition
-- 3. Add seasonal/temporal analysis of readmission patterns
-- 4. Risk-adjust readmission rates based on patient factors
-- 5. Compare readmission patterns across hospitals/regions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:35:28.143418
    - Additional Notes: Query focuses on 30-day readmission patterns but requires claims with valid admission and discharge dates. The synthetic nature of the SynMedPUF data means readmission patterns may not reflect real-world rates. Consider adding exclusions for planned readmissions in production use.
    
    */