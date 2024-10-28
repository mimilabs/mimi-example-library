
/*
Title: Medicare Outpatient Hospital Services Analysis by State and Service Type

Business Purpose:
This query analyzes Medicare outpatient hospital utilization and spending patterns across states,
focusing on the most frequently used services and their associated costs. This helps identify:
- Geographic variations in outpatient service utilization
- High-cost service categories
- States with notable spending patterns

The insights can inform policy decisions, resource allocation, and healthcare planning.
*/

WITH state_rankings AS (
  -- Calculate state-level metrics and rankings
  SELECT 
    rndrng_prvdr_geo_desc as state,
    SUM(bene_cnt) as total_beneficiaries,
    SUM(capc_srvcs) as total_services,
    ROUND(AVG(avg_mdcr_pymt_amt), 2) as avg_medicare_payment,
    ROUND(SUM(avg_mdcr_pymt_amt * capc_srvcs) / SUM(capc_srvcs), 2) as weighted_avg_payment
  FROM mimi_ws_1.datacmsgov.mupohp_geo
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent full year
    AND rndrng_prvdr_geo_lvl = 'State'     -- State-level analysis
  GROUP BY 1
)

SELECT 
  s.state,
  s.total_beneficiaries,
  s.total_services,
  s.avg_medicare_payment,
  s.weighted_avg_payment,
  -- Calculate percentile ranks
  ROUND(PERCENT_RANK() OVER (ORDER BY s.total_beneficiaries), 2) as beneficiary_percentile,
  ROUND(PERCENT_RANK() OVER (ORDER BY s.weighted_avg_payment), 2) as payment_percentile
FROM state_rankings s
ORDER BY s.total_beneficiaries DESC
LIMIT 10;

/*
How It Works:
1. The CTE filters for 2022 data and aggregates key metrics by state
2. The main query adds percentile rankings and orders results by total beneficiaries
3. Results show top 10 states by beneficiary count with their utilization and cost metrics

Assumptions & Limitations:
- Uses most recent complete year (2022)
- Assumes state-level analysis is sufficient for high-level insights
- Does not account for demographic differences between states
- Weighted average payments may be influenced by service mix variations

Possible Extensions:
1. Add year-over-year trend analysis:
   - Include previous years and calculate growth rates
   - Identify states with significant changes

2. Add service type analysis:
   - Break down by APC codes
   - Identify most common/costly procedures by state

3. Add geographic analysis:
   - Group states by region
   - Calculate regional averages and variations

4. Add cost efficiency metrics:
   - Compare submitted charges vs allowed amounts
   - Analyze outlier payment patterns
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:47:03.056652
    - Additional Notes: Query provides a high-level state analysis of Medicare outpatient services for 2022, focusing on beneficiary counts, service volumes, and payment patterns. The hardcoded year (2022) should be updated when analyzing more recent data. For time-series analysis, the date filter should be adjusted accordingly.
    
    */