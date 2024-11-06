-- dme_cost_burden_analysis.sql

-- Business Purpose:
-- - Analyze average out-of-pocket cost burden for Medicare beneficiaries using DME
-- - Compare beneficiary financial responsibility across states and equipment types
-- - Support policy discussions around DME affordability and coverage decisions
-- - Help identify areas where beneficiary cost-sharing may create access barriers

WITH beneficiary_costs AS (
  SELECT 
    rfrg_prvdr_geo_desc as state,
    rbcs_lvl as equipment_category,
    -- Calculate average beneficiary responsibility per service
    AVG(avg_suplr_mdcr_alowd_amt - avg_suplr_mdcr_pymt_amt) as avg_beneficiary_cost,
    -- Calculate total beneficiaries impacted
    SUM(tot_suplr_benes) as total_beneficiaries,
    -- Calculate percentage of allowed amount paid by beneficiaries
    AVG((avg_suplr_mdcr_alowd_amt - avg_suplr_mdcr_pymt_amt) / 
        NULLIF(avg_suplr_mdcr_alowd_amt, 0) * 100) as beneficiary_share_pct
  FROM mimi_ws_1.datacmsgov.mupdme_geo
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    AND rfrg_prvdr_geo_lvl = 'State'       -- State-level analysis
    AND tot_suplr_benes >= 11              -- Exclude suppressed beneficiary counts
  GROUP BY state, equipment_category
)
SELECT 
  state,
  equipment_category,
  ROUND(avg_beneficiary_cost, 2) as avg_beneficiary_cost,
  total_beneficiaries,
  ROUND(beneficiary_share_pct, 1) as beneficiary_share_pct
FROM beneficiary_costs
WHERE total_beneficiaries > 1000  -- Focus on categories with significant utilization
ORDER BY beneficiary_share_pct DESC, total_beneficiaries DESC
LIMIT 20;

-- How this query works:
-- 1. Calculates average beneficiary out-of-pocket costs per service by subtracting Medicare payment from allowed amount
-- 2. Determines beneficiary share as percentage of total allowed amount
-- 3. Aggregates results by state and equipment category
-- 4. Filters for significant utilization and ranks by beneficiary cost burden

-- Assumptions and limitations:
-- - Assumes 2022 data is most recent and complete
-- - Does not account for secondary insurance coverage
-- - Cannot track individual beneficiary total annual DME costs
-- - Excludes suppressed beneficiary counts (< 11)
-- - State-level aggregation may mask local variations

-- Possible extensions:
-- 1. Add year-over-year trend analysis of beneficiary cost burden
-- 2. Include rental vs. purchase cost burden comparison
-- 3. Correlate with state-level socioeconomic indicators
-- 4. Break down by specific HCPCS codes within equipment categories
-- 5. Compare urban vs. rural cost burden within states

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:09:10.975915
    - Additional Notes: The query provides insights into beneficiary financial burden but currently excludes critical factors like secondary insurance coverage and total out-of-pocket maximums. Results should be interpreted alongside other socioeconomic indicators for policy decisions.
    
    */