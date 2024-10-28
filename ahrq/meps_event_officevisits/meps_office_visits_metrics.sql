
/*******************************************************************************
Title: MEPS Office Visit Analysis - Key Healthcare Utilization and Cost Metrics

Business Purpose:
This query analyzes office-based medical visits to understand:
1. Volume and types of healthcare services provided
2. Payment patterns across different insurance types
3. Prevalence of telehealth vs in-person visits
4. Basic utilization patterns over time

This provides insights for healthcare policy, resource allocation and care delivery.
*******************************************************************************/

WITH visit_metrics AS (
  -- Calculate core visit metrics and costs
  SELECT 
    obdateyr as visit_year,
    COUNT(*) as total_visits,
    
    -- Service type breakdown
    SUM(CASE WHEN labtest = 1 THEN 1 ELSE 0 END) as lab_test_count,
    SUM(CASE WHEN rcvvac = 1 THEN 1 ELSE 0 END) as vaccination_count,
    SUM(CASE WHEN medpresc = 1 THEN 1 ELSE 0 END) as prescription_count,
    
    -- Visit mode
    SUM(CASE WHEN telehealthflag = 1 THEN 1 ELSE 0 END) as telehealth_visits,
    SUM(CASE WHEN seetlkpv = 1 THEN 1 ELSE 0 END) as in_person_visits,
    
    -- Payment metrics
    AVG(obxp_yy_x) as avg_total_payment,
    AVG(obmr_yy_x) as avg_medicare_payment,
    AVG(obmd_yy_x) as avg_medicaid_payment,
    AVG(obpv_yy_x) as avg_private_ins_payment
    
  FROM mimi_ws_1.ahrq.meps_event_officevisits
  WHERE obdateyr BETWEEN 2015 AND 2022
  GROUP BY obdateyr
)

SELECT
  visit_year,
  total_visits,
  
  -- Calculate service percentages
  ROUND(100.0 * lab_test_count/total_visits, 1) as pct_with_labs,
  ROUND(100.0 * vaccination_count/total_visits, 1) as pct_with_vaccines,
  ROUND(100.0 * prescription_count/total_visits, 1) as pct_with_rx,
  
  -- Calculate visit mode percentages  
  ROUND(100.0 * telehealth_visits/total_visits, 1) as pct_telehealth,
  ROUND(100.0 * in_person_visits/total_visits, 1) as pct_in_person,
  
  -- Format payment amounts
  ROUND(avg_total_payment, 2) as avg_payment_total,
  ROUND(avg_medicare_payment, 2) as avg_payment_medicare,
  ROUND(avg_medicaid_payment, 2) as avg_payment_medicaid,
  ROUND(avg_private_ins_payment, 2) as avg_payment_private
  
FROM visit_metrics
ORDER BY visit_year;

/*******************************************************************************
How the Query Works:
1. Creates temp table with raw visit counts and payment totals by year
2. Calculates percentages and formats final metrics in main query
3. Orders results chronologically

Key Assumptions & Limitations:
- Assumes valid payment data (non-null, positive values)
- Limited to 2015-2022 timeframe
- Does not account for sampling weights
- Basic metrics only - no risk adjustment or detailed stratification

Possible Extensions:
1. Add demographic breakdowns (age, gender, geography)
2. Analyze specific conditions or specialties
3. Include visit complexity indicators
4. Add statistical testing for trend analysis
5. Incorporate sampling weights for population estimates
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:58:41.910165
    - Additional Notes: The query provides a year-over-year trend analysis of healthcare visits and payments from MEPS data. When using this query, note that payment amounts are in original currency units and may need adjustment for inflation when comparing across years. The percentages calculated assume clean, non-null values in the denominator counts. The query does not apply MEPS survey weights, so results represent sample statistics rather than population estimates.
    
    */