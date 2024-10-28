
/***************************************************************
Title: Analysis of Prescription Medicine Costs and Payment Sources

Business Purpose:
This query analyzes prescription medicine expenditures and payment sources 
to understand healthcare spending patterns and insurance coverage.
It helps identify:
- Total prescription costs
- Payment distribution across different sources (private, public, out-of-pocket)
- Most expensive medications
***************************************************************/

WITH payment_summary AS (
  -- Calculate total payments and payment source distributions
  SELECT 
    rxname,
    COUNT(DISTINCT dupersid) as patient_count,
    
    -- Total payments
    ROUND(AVG(rxxp_yy_x),2) as avg_total_payment,
    
    -- Calculate payment source percentages
    ROUND(AVG(COALESCE(rxsf_yy_x,0)/NULLIF(rxxp_yy_x,0) * 100),1) as pct_self_pay,
    ROUND(AVG(COALESCE(rxpv_yy_x,0)/NULLIF(rxxp_yy_x,0) * 100),1) as pct_private_ins,
    ROUND(AVG(COALESCE(rxmd_yy_x,0)/NULLIF(rxxp_yy_x,0) * 100),1) as pct_medicaid,
    ROUND(AVG(COALESCE(rxmr_yy_x,0)/NULLIF(rxxp_yy_x,0) * 100),1) as pct_medicare
    
  FROM mimi_ws_1.ahrq.meps_event_prescribedmeds
  WHERE rxxp_yy_x > 0  -- Only include records with valid payment data
  GROUP BY rxname
)

SELECT
  rxname as medication_name,
  patient_count,
  avg_total_payment,
  pct_self_pay as percent_out_of_pocket,
  pct_private_ins as percent_private_insurance, 
  pct_medicaid as percent_medicaid,
  pct_medicare as percent_medicare

FROM payment_summary
WHERE patient_count >= 10  -- Filter for commonly prescribed medications
ORDER BY avg_total_payment DESC
LIMIT 20;

/***************************************************************
How it works:
1. Creates a CTE to aggregate payment data by medication
2. Calculates average total cost and percentage paid by each source
3. Filters for medications with sufficient sample size
4. Returns top 20 medications by cost

Assumptions & Limitations:
- Assumes payment amounts are adjusted for inflation
- Limited to medications with 10+ patients for statistical validity
- Percentages may not sum to 100% due to other payment sources
- Data quality depends on accurate reporting and coding

Possible Extensions:
1. Add trending analysis over multiple years
2. Break down by therapeutic class or medical condition
3. Include demographic factors (age, region, income level)
4. Analyze generic vs brand name cost differences
5. Compare pharmacy types and their pricing
***************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:38:40.056331
    - Additional Notes: Query requires aggregated payment amounts (rxxp_yy_x) to be valid (non-zero) and filters out medications with fewer than 10 patients to ensure statistical significance. Payment source percentages exclude some minor payment categories. The 20-record limit can be adjusted based on analysis needs.
    
    */