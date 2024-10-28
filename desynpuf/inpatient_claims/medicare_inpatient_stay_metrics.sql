
/*******************************************************************************
Title: Analysis of Medicare Inpatient Stay Patterns and Costs

Business Purpose:
This query analyzes key metrics around Medicare inpatient hospital stays to:
- Understand average length of stay and costs
- Identify high utilization patterns
- Track payment distributions
- Support hospital capacity and resource planning

This provides insights for:
- Healthcare cost management
- Hospital operations optimization
- Quality of care monitoring
- Resource allocation planning
*******************************************************************************/

WITH stay_metrics AS (
  -- Calculate key metrics for each inpatient stay
  SELECT 
    YEAR(clm_from_dt) as admission_year,
    clm_utlztn_day_cnt as length_of_stay,
    clm_pmt_amt as payment_amount,
    clm_pmt_amt / NULLIF(clm_utlztn_day_cnt, 0) as cost_per_day,
    icd9_dgns_cd_1 as primary_diagnosis
  FROM mimi_ws_1.desynpuf.inpatient_claims
  WHERE clm_from_dt IS NOT NULL 
    AND clm_utlztn_day_cnt > 0
)

SELECT
  admission_year,
  -- Calculate summary statistics
  COUNT(*) as total_stays,
  ROUND(AVG(length_of_stay), 1) as avg_length_of_stay,
  ROUND(AVG(payment_amount), 2) as avg_payment,
  ROUND(AVG(cost_per_day), 2) as avg_cost_per_day,
  -- Calculate cost distributions
  ROUND(PERCENTILE(payment_amount, 0.5), 2) as median_payment,
  ROUND(PERCENTILE(payment_amount, 0.75), 2) as p75_payment,
  -- Count stays by length categories  
  COUNT(CASE WHEN length_of_stay <= 3 THEN 1 END) as short_stays,
  COUNT(CASE WHEN length_of_stay > 7 THEN 1 END) as extended_stays
FROM stay_metrics
GROUP BY admission_year
ORDER BY admission_year;

/*******************************************************************************
How it works:
1. CTE calculates per-stay metrics including length and costs
2. Main query aggregates by year with summary statistics
3. Includes distributions and categorization of stays

Assumptions & Limitations:
- Assumes clm_utlztn_day_cnt accurately represents length of stay
- Only includes stays with valid dates and non-zero length
- Does not account for readmissions or transfers
- Uses synthetic data that may not fully represent real patterns

Possible Extensions:
1. Add diagnosis grouping to analyze costs by condition
2. Calculate readmission rates within 30/60/90 days
3. Add seasonal analysis by month
4. Compare metrics across providers
5. Analyze relationship between length of stay and outcomes
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:32:05.886020
    - Additional Notes: The query aggregates Medicare inpatient claims data by year to track key performance metrics like length of stay and costs. Note that the cost_per_day calculation assumes no zero-length stays (filtered in WHERE clause) and uses NULLIF to prevent division by zero errors. The synthetic nature of the DESYNPUF data means trends may not reflect actual Medicare patterns.
    
    */