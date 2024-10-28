
/*************************************************************************
* Analysis of Medicare Inpatient Claims - Key Utilization Metrics
*************************************************************************
* Business Purpose:
* This query analyzes Medicare inpatient claims to understand key metrics around
* hospital utilization, costs, and diagnoses. These insights help identify
* patterns in healthcare delivery and resource consumption.
*
* The metrics include:
* - Total claims and unique beneficiaries  
* - Average length of stay and payment amounts
* - Sample of diagnoses and discharge statuses
*************************************************************************/

WITH claim_metrics AS (
  -- Get key metrics per claim
  SELECT 
    bene_id,
    clm_id,
    clm_from_dt,
    clm_thru_dt,
    clm_pmt_amt,
    clm_tot_chrg_amt,
    ptnt_dschrg_stus_cd,
    prncpal_dgns_cd,
    -- Calculate length of stay
    datediff(clm_thru_dt, clm_from_dt) as length_of_stay
  FROM mimi_ws_1.synmedpuf.inpatient
)

SELECT
  -- Overall volume metrics
  COUNT(DISTINCT bene_id) as total_patients,
  COUNT(DISTINCT clm_id) as total_claims,
  COUNT(DISTINCT clm_id)/COUNT(DISTINCT bene_id) as claims_per_patient,
  
  -- Cost metrics
  ROUND(AVG(clm_pmt_amt),2) as avg_payment_amt,
  ROUND(AVG(clm_tot_chrg_amt),2) as avg_total_charges,
  ROUND(AVG(length_of_stay),1) as avg_length_of_stay,

  -- Sample of distinct values for categorical fields
  array_join(array_agg(DISTINCT ptnt_dschrg_stus_cd), ', ') as discharge_statuses,
  array_join(array_agg(DISTINCT prncpal_dgns_cd), ', ') as diagnoses

FROM claim_metrics;

/************************************************************************
* How this query works:
* 1. CTE extracts core metrics per claim and calculates length of stay
* 2. Main query aggregates to get summary statistics across all claims
* 3. Uses array functions to show distributions of categorical fields
*
* Assumptions & Limitations:
* - Uses clm_from_dt/thru_dt for length of stay calculation
* - Limited to basic metrics from claim header level
* - No filtering by date range or other criteria
* - Diagnosis codes not mapped to descriptions
* - Shows all distinct values for categorical fields
*
* Possible Extensions:
* 1. Add date range filters to analyze trends over time
* 2. Join to diagnosis code reference table for descriptions
* 3. Break down metrics by patient demographics
* 4. Analyze readmission patterns
* 5. Compare metrics across hospitals/regions
* 6. Add cost analysis by DRG
*************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:16:29.636901
    - Additional Notes: Query provides a high-level overview of Medicare inpatient claims, focusing on utilization metrics (patient counts, costs, length of stay) and basic categorical distributions. Note that array_agg without sorting may return inconsistent ordering of discharge statuses and diagnoses across runs. For production use, consider adding date filters and joining with reference tables for diagnosis code descriptions.
    
    */