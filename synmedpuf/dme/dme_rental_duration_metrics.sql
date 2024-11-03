-- DME Claims Analysis - Utilization Patterns by Service Duration
--
-- Business Purpose:
--   Analyze Medicare DME claims to understand:
--   - Rental vs purchase patterns for DME equipment
--   - Service duration trends and billing patterns
--   - Equipment utilization efficiency metrics 
--   This helps identify opportunities for cost optimization and improved patient care.

WITH service_duration AS (
  SELECT 
    hcpcs_cd,
    betos_cd,
    -- Calculate service duration in days
    DATEDIFF(line_last_expns_dt, line_1st_expns_dt) + 1 as service_days,
    line_srvc_cnt,
    line_alowd_chrg_amt,
    -- Identify rental claims based on modifiers
    CASE WHEN hcpcs_1st_mdfr_cd IN ('RR','LL') THEN 'Rental' 
         WHEN hcpcs_1st_mdfr_cd IN ('NU','UE') THEN 'Purchase'
         ELSE 'Other' END as rental_status
  FROM mimi_ws_1.synmedpuf.dme
  WHERE line_last_expns_dt >= line_1st_expns_dt  -- Valid date ranges only
)

SELECT
  rental_status,
  COUNT(*) as claim_count,
  ROUND(AVG(service_days),1) as avg_service_days,
  ROUND(AVG(line_srvc_cnt),1) as avg_service_units,
  ROUND(AVG(line_alowd_chrg_amt),2) as avg_allowed_amount,
  -- Calculate cost per day
  ROUND(SUM(line_alowd_chrg_amt)/NULLIF(SUM(service_days),0),2) as cost_per_service_day
FROM service_duration
GROUP BY rental_status
ORDER BY claim_count DESC;

-- How this query works:
-- 1. Creates CTE to calculate service duration and classify rental status
-- 2. Aggregates key metrics by rental vs purchase status
-- 3. Calculates efficiency metrics like cost per service day

-- Assumptions and Limitations:
-- - Relies on standard HCPCS modifiers to identify rentals vs purchases
-- - Service duration calculations assume continuous use between start/end dates
-- - Cost per day metrics may not reflect actual utilization patterns

-- Possible Extensions:
-- 1. Add trending over time to identify seasonal patterns
-- 2. Break down by specific equipment categories using HCPCS codes
-- 3. Analyze geographic variations in rental vs purchase patterns
-- 4. Compare duration patterns across different patient diagnoses
-- 5. Add provider-level analysis of rental practices

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:11:11.041000
    - Additional Notes: Query focuses on service duration metrics differentiated by rental vs purchase status. Results help identify opportunities for cost optimization based on equipment utilization patterns. Key limitation is reliance on HCPCS modifiers for rental classification which may not capture all rental scenarios.
    
    */