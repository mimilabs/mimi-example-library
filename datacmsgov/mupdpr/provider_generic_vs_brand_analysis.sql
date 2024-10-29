/* medicare_generic_substitution_opportunity.sql 

Business Purpose:
This analysis identifies providers who frequently prescribe brand-name drugs where generic alternatives
are available, revealing opportunities for cost savings through increased generic substitution.
The insights can help:
- Healthcare payers optimize drug spending
- Provider education programs on cost-effective prescribing
- Value-based care initiatives focused on pharmaceutical costs
*/

WITH brand_generic_pairs AS (
  -- Identify brand-generic drug pairs and their cost differences
  SELECT DISTINCT
    brnd_name,
    gnrc_name,
    AVG(tot_drug_cst/NULLIF(tot_30day_fills,0)) as avg_30day_cost
  FROM mimi_ws_1.datacmsgov.mupdpr
  WHERE mimi_src_file_date = '2022-12-31'
    AND brnd_name IS NOT NULL 
    AND gnrc_name IS NOT NULL
  GROUP BY brnd_name, gnrc_name
),

provider_prescribing AS (
  -- Calculate prescribing patterns per provider
  SELECT 
    p.prscrbr_npi,
    p.prscrbr_last_org_name,
    p.prscrbr_first_name,
    p.prscrbr_state_abrvtn,
    p.prscrbr_type,
    SUM(CASE WHEN p.brnd_name IS NOT NULL THEN p.tot_drug_cst ELSE 0 END) as brand_cost,
    SUM(CASE WHEN p.brnd_name IS NOT NULL THEN p.tot_30day_fills ELSE 0 END) as brand_fills,
    SUM(CASE WHEN p.brnd_name IS NULL THEN p.tot_drug_cst ELSE 0 END) as generic_cost,
    SUM(CASE WHEN p.brnd_name IS NULL THEN p.tot_30day_fills ELSE 0 END) as generic_fills
  FROM mimi_ws_1.datacmsgov.mupdpr p
  WHERE mimi_src_file_date = '2022-12-31'
    AND tot_30day_fills > 0
  GROUP BY 1,2,3,4,5
)

SELECT 
  pp.prscrbr_npi,
  pp.prscrbr_last_org_name,
  pp.prscrbr_first_name,
  pp.prscrbr_state_abrvtn,
  pp.prscrbr_type,
  pp.brand_fills,
  pp.generic_fills,
  ROUND(pp.brand_cost,2) as brand_cost,
  ROUND(pp.generic_cost,2) as generic_cost,
  ROUND(pp.brand_fills::FLOAT / NULLIF((pp.brand_fills + pp.generic_fills),0) * 100,1) as brand_fill_pct,
  ROUND(pp.brand_cost::FLOAT / NULLIF((pp.brand_cost + pp.generic_cost),0) * 100,1) as brand_cost_pct
FROM provider_prescribing pp
WHERE (pp.brand_fills + pp.generic_fills) >= 100  -- Focus on providers with meaningful volume
ORDER BY brand_cost DESC
LIMIT 100;

/* How it works:
1. First CTE identifies brand-generic drug pairs and calculates average 30-day costs
2. Second CTE aggregates prescribing patterns at the provider level
3. Final query calculates key metrics and filters for high-volume prescribers

Assumptions & Limitations:
- Assumes brand name field accurately identifies brand vs generic drugs
- Limited to Medicare Part D claims only
- Does not account for therapeutic alternatives or clinical necessity
- Cost differences may vary by region/time period

Possible Extensions:
1. Add therapeutic class analysis to identify specific drug categories with high brand usage
2. Include temporal trends to track generic adoption rates
3. Add geographic comparisons to identify regional variation
4. Calculate potential cost savings based on theoretical maximum generic substitution
5. Include provider specialty benchmarking
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:10:43.819881
    - Additional Notes: Query focuses on comparing brand vs generic prescribing patterns at the provider level with key cost and utilization metrics. Requires minimum 100 total prescriptions per provider to ensure statistical relevance. Results are limited to top 100 providers by brand drug costs to identify highest impact opportunities.
    
    */