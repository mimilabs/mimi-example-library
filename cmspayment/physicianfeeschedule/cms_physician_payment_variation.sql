
/*******************************************************************************
Title: CMS Physician Fee Schedule Payment Analysis - Core Query
 
Business Purpose:
This query analyzes Medicare physician fee schedule payment amounts across localities
to understand reimbursement variations and identify potential cost optimization 
opportunities. The analysis focuses on non-facility vs facility payment differences
for active procedures.

Key business questions addressed:
- What are the payment variations across localities for common procedures?
- How do facility vs non-facility payments compare?
- Which procedures have the largest payment differentials?
*******************************************************************************/

WITH active_procedures AS (
  -- Filter to active procedures with both facility and non-facility amounts
  SELECT DISTINCT
    hcpcs_code,
    year,
    locality,
    non_facility_fee_schedule_amount,
    facility_fee_schedule_amount,
    (non_facility_fee_schedule_amount - facility_fee_schedule_amount) as payment_differential
  FROM mimi_ws_1.cmspayment.physicianfeeschedule
  WHERE status_code = 'A'  -- Active codes only
    AND year = 2024       -- Most recent year
    AND non_facility_fee_schedule_amount > 0 
    AND facility_fee_schedule_amount > 0
)

SELECT
  hcpcs_code,
  
  -- Payment statistics across localities
  COUNT(DISTINCT locality) as num_localities,
  
  -- Non-facility payment analysis
  ROUND(AVG(non_facility_fee_schedule_amount),2) as avg_non_facility_payment,
  ROUND(MIN(non_facility_fee_schedule_amount),2) as min_non_facility_payment, 
  ROUND(MAX(non_facility_fee_schedule_amount),2) as max_non_facility_payment,
  
  -- Facility payment analysis
  ROUND(AVG(facility_fee_schedule_amount),2) as avg_facility_payment,
  ROUND(MIN(facility_fee_schedule_amount),2) as min_facility_payment,
  ROUND(MAX(facility_fee_schedule_amount),2) as max_facility_payment,
  
  -- Payment differential analysis
  ROUND(AVG(payment_differential),2) as avg_payment_differential,
  ROUND(MAX(payment_differential),2) as max_payment_differential

FROM active_procedures
GROUP BY hcpcs_code
HAVING COUNT(DISTINCT locality) > 1  -- Only show codes used in multiple localities
ORDER BY avg_payment_differential DESC
LIMIT 100;

/*******************************************************************************
How this works:
1. CTE filters to active procedures with both facility/non-facility payments
2. Main query calculates payment statistics across localities
3. Results ordered by payment differential to highlight largest variations

Assumptions/Limitations:
- Uses most recent year data (2024)
- Only includes active procedure codes
- Requires both facility and non-facility payments to be > 0
- Limited to top 100 procedures by payment differential

Possible Extensions:
1. Add procedure descriptions and specialty information
2. Analyze geographic patterns in payment variations
3. Track payment trends over multiple years
4. Include modifier analysis for component payments
5. Add volume/utilization data if available
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:49:40.331067
    - Additional Notes: The query focuses on payment differentials between facility and non-facility settings, which is key for healthcare cost analysis. Note that results are limited to the top 100 procedures by payment differential and require both facility and non-facility payments to be present, which may exclude some relevant procedures with single-setting payments.
    
    */