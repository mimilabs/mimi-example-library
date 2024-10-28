
/* 
Title: Outpatient Visit Utilization and Cost Analysis

Business Purpose:
This query analyzes key metrics around outpatient visit utilization and costs to help:
- Understand patterns in outpatient service usage 
- Identify cost drivers and payment sources
- Support healthcare resource planning and cost management
*/

WITH visit_summary AS (
  -- Calculate core visit metrics by year
  SELECT 
    opdateyr as visit_year,
    COUNT(*) as total_visits,
    
    -- Service type breakdown
    SUM(CASE WHEN labtest = 1 THEN 1 ELSE 0 END) as lab_test_count,
    SUM(CASE WHEN xrays = 1 THEN 1 ELSE 0 END) as xray_count,
    SUM(CASE WHEN mri = 1 THEN 1 ELSE 0 END) as mri_count,
    
    -- Cost metrics
    AVG(opxp_yy_x) as avg_total_cost,
    AVG(opfpv_yy_x) as avg_private_insurance_paid,
    AVG(opfmr_yy_x) as avg_medicare_paid,
    AVG(opfmd_yy_x) as avg_medicaid_paid,
    AVG(opfsf_yy_x) as avg_self_paid
  FROM mimi_ws_1.ahrq.meps_event_outpatientvisits
  WHERE opdateyr IS NOT NULL
  GROUP BY opdateyr
)

SELECT
  visit_year,
  total_visits,
  
  -- Calculate service mix percentages
  ROUND(100.0 * lab_test_count / total_visits, 1) as pct_with_labs,
  ROUND(100.0 * xray_count / total_visits, 1) as pct_with_xray,
  ROUND(100.0 * mri_count / total_visits, 1) as pct_with_mri,
  
  -- Format cost metrics
  ROUND(avg_total_cost, 2) as avg_cost_per_visit,
  ROUND(avg_private_insurance_paid, 2) as avg_private_ins_paid,
  ROUND(avg_medicare_paid, 2) as avg_medicare_paid,
  ROUND(avg_medicaid_paid, 2) as avg_medicaid_paid,
  ROUND(avg_self_paid, 2) as avg_self_paid

FROM visit_summary
ORDER BY visit_year;

/*
How it works:
1. Creates a CTE to aggregate core visit and cost metrics by year
2. Calculates percentages of visits with key services
3. Summarizes average payments by major funding sources

Assumptions & Limitations:
- Assumes cost fields are populated and accurate
- Limited to basic service types and payment sources
- Does not account for visit complexity or patient demographics
- Year-over-year comparisons may be affected by changes in data collection

Possible Extensions:
1. Add patient demographic breakdowns (age, gender, geography)
2. Include diagnosis/condition analysis using opccc fields
3. Compare telehealth vs in-person visits
4. Analyze seasonal patterns using opdatemm
5. Add statistical testing for trend analysis
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:33:40.859421
    - Additional Notes: Query provides year-over-year analysis of outpatient visit costs and service utilization. Cost metrics are based on available payment fields which may have missing data in some years. Service type percentages represent minimum values as some visits may have incomplete service documentation.
    
    */