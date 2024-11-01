/* Medicare Inpatient Claims - Length of Stay and Financial Impact Analysis

Business Purpose:
This query analyzes the relationship between length of stay and financial metrics
for Medicare inpatient claims. Understanding these patterns helps:
- Identify opportunities for length of stay optimization
- Assess financial implications of extended stays
- Support care management and discharge planning initiatives
- Provide insights for contract negotiations with facilities

The analysis generates key metrics at the provider level to enable targeted interventions.
*/

WITH stay_metrics AS (
  -- Calculate length of stay and financial metrics per claim
  SELECT 
    prvdr_num,
    prvdr_state_cd,
    clm_id,
    DATEDIFF(clm_thru_dt, clm_from_dt) AS length_of_stay,
    clm_pmt_amt,
    clm_tot_chrg_amt,
    clm_drg_cd
  FROM mimi_ws_1.synmedpuf.inpatient
  WHERE clm_from_dt IS NOT NULL 
    AND clm_thru_dt IS NOT NULL
    AND clm_pmt_amt > 0
),

provider_summary AS (
  -- Aggregate metrics at provider level
  SELECT
    prvdr_num,
    prvdr_state_cd,
    COUNT(DISTINCT clm_id) as total_claims,
    AVG(length_of_stay) as avg_los,
    STDDEV(length_of_stay) as std_dev_los,
    AVG(clm_pmt_amt) as avg_payment,
    AVG(clm_tot_chrg_amt) as avg_charges,
    AVG(clm_pmt_amt/NULLIF(length_of_stay,0)) as avg_payment_per_day
  FROM stay_metrics
  GROUP BY prvdr_num, prvdr_state_cd
)

-- Final output with provider rankings
SELECT 
  p.*,
  RANK() OVER (ORDER BY avg_los DESC) as los_rank,
  RANK() OVER (ORDER BY avg_payment_per_day DESC) as cost_rank
FROM provider_summary p
WHERE total_claims >= 10  -- Filter for providers with meaningful volume
ORDER BY avg_los DESC
LIMIT 100;

/* How the Query Works:
1. stay_metrics CTE calculates length of stay and captures key financial metrics per claim
2. provider_summary CTE aggregates metrics at the provider level
3. Final SELECT adds rankings and filters for providers with sufficient volume

Assumptions and Limitations:
- Assumes claim dates are accurate and complete
- Excludes claims with $0 payments to focus on paid claims
- Minimum threshold of 10 claims per provider may need adjustment
- Does not account for patient severity or case mix

Possible Extensions:
1. Add DRG-level analysis to compare within similar case types
2. Include patient demographic factors
3. Add trending over time to identify patterns
4. Incorporate quality metrics to assess LOS impact on outcomes
5. Add geographical analysis using provider state codes
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:44:11.371702
    - Additional Notes: Query focuses on facility-level length of stay and cost metrics. Required fields: prvdr_num, clm_id, clm_from_dt, clm_thru_dt, clm_pmt_amt, clm_tot_chrg_amt. Performance may be impacted with large datasets due to window functions and standard deviation calculations.
    
    */