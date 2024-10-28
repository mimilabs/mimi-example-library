
/* 
Medicare Inpatient Hospital State-Level Cost Analysis

Business Purpose:
This query analyzes state-level variations in Medicare inpatient hospital costs and utilization
for the most recent year of data. It identifies states with the highest average Medicare payments
and discharge volumes to help identify potential cost drivers and regional variations in care delivery.

Key metrics analyzed:
- Average Medicare payment per discharge
- Total discharges 
- Total Medicare payments
*/

WITH recent_year AS (
  -- Get the most recent year of data
  SELECT MAX(mimi_src_file_date) as max_date
  FROM mimi_ws_1.datacmsgov.mupihp_geo
),

state_metrics AS (
  -- Calculate state-level metrics
  SELECT 
    g.rndrng_prvdr_geo_desc as state_name,
    COUNT(DISTINCT drg_cd) as unique_drgs,
    SUM(tot_dschrgs) as total_discharges,
    SUM(tot_dschrgs * avg_mdcr_pymt_amt) as total_medicare_payments,
    SUM(tot_dschrgs * avg_mdcr_pymt_amt) / SUM(tot_dschrgs) as avg_payment_per_discharge
  FROM mimi_ws_1.datacmsgov.mupihp_geo g
  CROSS JOIN recent_year r
  WHERE g.mimi_src_file_date = r.max_date
    AND g.rndrng_prvdr_geo_lvl = 'State'
  GROUP BY g.rndrng_prvdr_geo_desc
)

SELECT 
  state_name,
  unique_drgs,
  total_discharges,
  ROUND(total_medicare_payments, 2) as total_medicare_payments,
  ROUND(avg_payment_per_discharge, 2) as avg_payment_per_discharge,
  -- Calculate percentile ranks to identify outliers
  ROUND(PERCENT_RANK() OVER (ORDER BY avg_payment_per_discharge) * 100, 1) as payment_percentile,
  ROUND(PERCENT_RANK() OVER (ORDER BY total_discharges) * 100, 1) as volume_percentile
FROM state_metrics
ORDER BY avg_payment_per_discharge DESC
LIMIT 10;

/*
How the Query Works:
1. Identifies most recent data year using MAX(mimi_src_file_date)
2. Calculates key metrics for each state:
   - Unique DRGs to measure service variety
   - Total discharges for volume
   - Total and average Medicare payments for cost analysis
3. Adds percentile ranks to identify statistical outliers
4. Returns top 10 states by average payment per discharge

Assumptions & Limitations:
- Uses most recent year only - trends over time not analyzed
- Focuses on Medicare payments, not total charges or other payers
- State-level analysis may mask facility-level variations
- Does not account for differences in patient demographics or case mix

Possible Extensions:
1. Add year-over-year trend analysis
2. Include DRG-level analysis to identify specific high-cost services
3. Compare Medicare payments vs submitted charges
4. Add geographic region groupings
5. Correlate with quality metrics or demographic data
6. Analyze seasonal patterns in discharges
7. Compare state metrics to national averages
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:58:12.604813
    - Additional Notes: Query calculates state-level Medicare inpatient costs and utilization metrics from the most recent available year. The results are limited to top 10 states by payment per discharge. Payment calculations include all Medicare payments (DRG amount, teaching, disproportionate share, capital, and outlier payments) but exclude beneficiary co-payments and third-party payments.
    
    */