
/* Medicare Part D High-Cost Prescriber Analysis
 
This query identifies high-volume/high-cost prescribers in the Medicare Part D program
to understand prescription drug spending patterns and potential cost-saving opportunities.

Business Purpose:
- Identify prescribers with high prescription costs and volumes
- Compare brand vs generic prescribing patterns 
- Surface opportunities for cost optimization in Medicare Part D
*/

WITH prescriber_totals AS (
  -- Calculate key metrics by prescriber
  SELECT 
    prscrbr_npi,
    prscrbr_last_org_name,
    prscrbr_first_name,
    prscrbr_state_abrvtn,
    prscrbr_type,
    SUM(tot_drug_cst) as total_cost,
    SUM(tot_clms) as total_claims,
    SUM(CASE WHEN brnd_name != '' THEN tot_drug_cst ELSE 0 END) as brand_cost,
    SUM(CASE WHEN brnd_name = '' THEN tot_drug_cst ELSE 0 END) as generic_cost
  FROM mimi_ws_1.datacmsgov.mupdpr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
  GROUP BY 1,2,3,4,5
),

ranked_prescribers AS (
  -- Rank prescribers by total cost
  SELECT 
    *,
    brand_cost / NULLIF(total_cost,0) as brand_pct,
    ROW_NUMBER() OVER (ORDER BY total_cost DESC) as cost_rank
  FROM prescriber_totals
  WHERE total_cost > 0
)

SELECT
  prscrbr_last_org_name as prescriber_name,
  prscrbr_first_name as first_name,
  prscrbr_state_abrvtn as state,
  prscrbr_type as specialty,
  ROUND(total_cost,2) as total_drug_cost,
  total_claims,
  ROUND(total_cost/total_claims,2) as cost_per_claim,
  ROUND(brand_pct * 100,1) as brand_name_pct
FROM ranked_prescribers
WHERE cost_rank <= 100 -- Top 100 by cost
ORDER BY total_drug_cost DESC;

/* How this query works:
1. Aggregates prescription costs and claims by prescriber
2. Calculates brand vs generic cost ratios
3. Ranks prescribers by total cost
4. Returns top 100 prescribers with key metrics

Assumptions & Limitations:
- Uses most recent full year of data (2022)
- Focuses only on highest-cost prescribers
- Does not account for differences in patient populations
- Brand vs generic classification based on brand name presence

Possible Extensions:
1. Add geographic analysis by state/region
2. Include specialty-specific benchmarking
3. Add year-over-year trend analysis
4. Include specific drug category analysis
5. Add risk-adjusted cost comparisons
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:08:42.402539
    - Additional Notes: The query assumes presence of 2022 data in mimi_src_file_date field. For other years, modify the date filter accordingly. Total cost calculations include all components (ingredient cost, dispensing fee, sales tax, etc.). Brand percentage calculations may be affected by data quality of brand_name field.
    
    */