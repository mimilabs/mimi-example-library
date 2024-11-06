-- MEPS Office Visit Cost Analysis by Service Type and Patient Impact
--
-- Business Purpose:
-- This analysis helps healthcare organizations understand:
-- 1. Total cost burden and distribution across different diagnostic services
-- 2. Patient access patterns for key diagnostic procedures
-- 3. Cost variation trends to identify potential savings opportunities
-- 4. Service utilization patterns to optimize resource allocation

WITH diagnostic_services AS (
  -- Aggregate diagnostic services and associated costs per visit
  SELECT 
    evntidx,
    obdateyr,
    CASE 
      WHEN labtest = 1 THEN 'Lab Tests'
      WHEN xrays = 1 THEN 'X-Rays'
      WHEN mri = 1 THEN 'MRI/CT'
      WHEN sonogram = 1 THEN 'Ultrasound'
      WHEN mammog = 1 THEN 'Mammogram'
      WHEN ekg = 1 THEN 'EKG'
      ELSE 'Other Services'
    END AS service_type,
    obtc_yy_x as total_charge,
    obxp_yy_x as total_paid,
    perwt_yy_f as patient_weight
  FROM mimi_ws_1.ahrq.meps_event_officevisits
  WHERE obdateyr >= 2019
)

SELECT
  service_type,
  obdateyr as year,
  COUNT(DISTINCT evntidx) as service_count,
  ROUND(AVG(total_charge), 2) as avg_charge,
  ROUND(AVG(total_paid), 2) as avg_paid,
  ROUND(SUM(total_paid * patient_weight) / 1000000, 2) as weighted_total_paid_millions
FROM diagnostic_services
WHERE total_charge > 0 
  AND total_paid > 0
GROUP BY service_type, obdateyr
ORDER BY obdateyr DESC, weighted_total_paid_millions DESC;

-- How this query works:
-- 1. Creates a CTE to classify diagnostic services and extract relevant cost metrics
-- 2. Calculates key metrics including service counts and average costs
-- 3. Applies population weights to estimate national totals
-- 4. Filters for valid charges and payments to ensure data quality

-- Assumptions and Limitations:
-- 1. Services are mutually exclusive (each visit classified under primary service)
-- 2. Cost data is available and valid (non-zero values)
-- 3. Population weights are appropriate for national estimates
-- 4. Limited to years 2019 and later for recent trends

-- Possible Extensions:
-- 1. Add geographic analysis by incorporating regional variables
-- 2. Include insurance type breakdown of payments
-- 3. Compare costs between in-person and telehealth visits
-- 4. Analyze seasonal patterns in service utilization
-- 5. Include provider specialty impact on costs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:23:47.030888
    - Additional Notes: The query weights results using MEPS survey weights (perwt_yy_f) for national estimates. Cost calculations exclude zero-charge visits which may impact completeness. Service categories are mutually exclusive based on primary procedure, potentially undercounting multiple-service visits.
    
    */