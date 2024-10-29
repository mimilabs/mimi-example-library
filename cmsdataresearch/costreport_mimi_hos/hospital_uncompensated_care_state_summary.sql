/* Hospital Uncompensated Care and Charity Analysis
   
Business Purpose:
This query analyzes hospital uncompensated care, charity care, and bad debt patterns
to understand healthcare access and financial assistance trends. This helps:
- Evaluate community benefit and safety net roles of hospitals
- Assess financial burden of providing care to uninsured/underinsured 
- Guide policy decisions around healthcare coverage and assistance programs
*/

WITH hospital_metrics AS (
  SELECT 
    fiscal_year_end_date,
    hospital_name,
    state_code,
    city,
    type_of_control,
    rural_versus_urban,
    
    -- Core uncompensated care metrics
    cost_of_charity_care,
    total_bad_debt_expense,
    cost_of_uncompensated_care,
    total_unreimbursed_and_uncompensated_care,
    
    -- Size/volume context 
    total_costs,
    total_patient_revenue,
    number_of_beds,
    
    -- Calculate key ratios
    ROUND(cost_of_charity_care / NULLIF(total_costs, 0) * 100, 2) as charity_care_pct,
    ROUND(total_bad_debt_expense / NULLIF(total_costs, 0) * 100, 2) as bad_debt_pct,
    ROUND(cost_of_uncompensated_care / NULLIF(total_costs, 0) * 100, 2) as uncompensated_care_pct
    
  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hos
  WHERE fiscal_year_end_date IS NOT NULL
    AND total_costs > 0
)

SELECT
  state_code,
  COUNT(DISTINCT hospital_name) as hospital_count,
  ROUND(AVG(charity_care_pct), 2) as avg_charity_care_pct,
  ROUND(AVG(bad_debt_pct), 2) as avg_bad_debt_pct,
  ROUND(AVG(uncompensated_care_pct), 2) as avg_uncompensated_care_pct,
  ROUND(SUM(cost_of_charity_care)/1000000, 2) as total_charity_care_millions,
  ROUND(SUM(total_bad_debt_expense)/1000000, 2) as total_bad_debt_millions,
  ROUND(SUM(cost_of_uncompensated_care)/1000000, 2) as total_uncompensated_millions
FROM hospital_metrics
GROUP BY state_code
ORDER BY total_uncompensated_millions DESC;

/* How this works:
1. CTE calculates key uncompensated care metrics and ratios for each hospital
2. Main query aggregates to state level to show geographic patterns
3. Results show charity care, bad debt, and total uncompensated care both as
   percentages of costs and absolute dollars

Assumptions & Limitations:
- Relies on accurate hospital reporting of charity care and bad debt
- Does not account for differences in hospital charity care policies
- Dollar amounts not adjusted for regional cost differences
- Some hospitals may have incomplete/missing data

Possible Extensions:
1. Add time series analysis to show trends over fiscal years
2. Break out by hospital characteristics (size, urban/rural, ownership)
3. Include Medicaid/Medicare metrics for fuller safety net analysis 
4. Add geographic visualizations of uncompensated care burden
5. Analyze correlation with community socioeconomic indicators
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:15:08.384176
    - Additional Notes: Query is most useful for state-level policy analysis and benchmarking. Data quality depends heavily on consistent reporting practices across hospitals. Results should be interpreted alongside local healthcare market conditions and state-specific Medicaid policies.
    
    */