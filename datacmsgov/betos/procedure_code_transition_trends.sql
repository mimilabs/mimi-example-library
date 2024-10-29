-- Current vs Historical Procedure Code Transitions Analysis
--
-- Business Purpose: 
-- Analyzes Medicare Part B procedure code transitions to identify which services are being 
-- replaced, retired, or newly introduced. This helps healthcare organizations:
-- 1. Update revenue cycle systems and billing practices
-- 2. Plan for service line changes
-- 3. Track evolution of medical procedures over time

WITH current_codes AS (
  SELECT DISTINCT
    hcpcs_cd,
    rbcs_cat_desc,
    rbcs_subcat_desc,
    rbcs_family_desc,
    hcpcs_cd_add_dt,
    hcpcs_cd_end_dt
  FROM mimi_ws_1.datacmsgov.betos
  WHERE hcpcs_cd_end_dt IS NULL  -- Currently active codes
),

historical_codes AS (
  SELECT DISTINCT
    hcpcs_cd,
    rbcs_cat_desc,
    rbcs_subcat_desc,
    rbcs_family_desc,
    hcpcs_cd_add_dt,
    hcpcs_cd_end_dt
  FROM mimi_ws_1.datacmsgov.betos
  WHERE hcpcs_cd_end_dt IS NOT NULL  -- Ended codes
)

SELECT
  cc.rbcs_cat_desc,
  cc.rbcs_subcat_desc,
  COUNT(DISTINCT cc.hcpcs_cd) as active_codes,
  COUNT(DISTINCT hc.hcpcs_cd) as retired_codes,
  ROUND(COUNT(DISTINCT cc.hcpcs_cd) * 100.0 / 
    (COUNT(DISTINCT cc.hcpcs_cd) + COUNT(DISTINCT hc.hcpcs_cd)), 1) as active_pct,
  MIN(cc.hcpcs_cd_add_dt) as earliest_active_code_date,
  MAX(hc.hcpcs_cd_end_dt) as latest_retired_code_date
FROM current_codes cc
FULL OUTER JOIN historical_codes hc 
  ON cc.rbcs_cat_desc = hc.rbcs_cat_desc 
  AND cc.rbcs_subcat_desc = hc.rbcs_subcat_desc
GROUP BY 
  cc.rbcs_cat_desc,
  cc.rbcs_subcat_desc
ORDER BY 
  active_codes DESC

/*
How this works:
- Creates two CTEs to separate currently active vs historical (ended) procedure codes
- Joins them to compare active vs retired codes within each category/subcategory
- Calculates key metrics including counts, percentages and relevant dates
- Results show where service categories are growing vs contracting

Assumptions/Limitations:
- Assumes NULL end_date indicates currently active code
- Does not account for seasonal or temporary codes
- Cannot determine if retired codes were replaced or eliminated
- No volume/utilization data included

Possible Extensions:
1. Add trend analysis by analyzing code changes over specific time periods
2. Include procedure complexity indicators to track shifts in service delivery
3. Cross-reference with specialty/provider types most impacted by changes
4. Add geographic analysis to identify regional variation in code adoption
5. Compare against reimbursement data to assess financial impact
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:17:43.241008
    - Additional Notes: Query focuses on tracking the evolution of Medicare procedure codes over time, showing areas of medical service delivery that are growing or contracting. Best used for quarterly/annual planning cycles when analyzing service line changes. May require additional filtering if analyzing specific date ranges or specialties.
    
    */