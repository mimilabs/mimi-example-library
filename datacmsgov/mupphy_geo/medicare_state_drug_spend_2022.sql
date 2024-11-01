-- medicare_geo_drug_spend_analysis.sql
--
-- Business Purpose: Analyze Medicare Part B drug spending patterns across states to identify:
-- 1. High-cost drug utilization trends 
-- 2. Geographic variations in drug pricing and reimbursement
-- 3. Opportunities for drug cost management and formulary optimization
--
-- This analysis helps healthcare organizations and payers:
-- - Develop targeted drug management strategies
-- - Negotiate pharmaceutical contracts
-- - Optimize formulary designs
-- - Identify potential cost saving opportunities

WITH drug_costs AS (
  SELECT 
    rndrng_prvdr_geo_desc as state,
    hcpcs_cd,
    hcpcs_desc,
    tot_benes,
    tot_srvcs,
    avg_mdcr_pymt_amt,
    (tot_srvcs * avg_mdcr_pymt_amt) as total_spend,
    ROW_NUMBER() OVER (PARTITION BY rndrng_prvdr_geo_desc ORDER BY (tot_srvcs * avg_mdcr_pymt_amt) DESC) as spend_rank
  FROM mimi_ws_1.datacmsgov.mupphy_geo
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent full year
    AND rndrng_prvdr_geo_lvl = 'State'     -- State-level analysis
    AND hcpcs_drug_ind = 'Y'               -- Drug services only
),

state_rankings AS (
  SELECT
    state,
    SUM(total_spend) as state_total_drug_spend,
    SUM(tot_benes) as state_total_benes,
    SUM(total_spend)/NULLIF(SUM(tot_benes), 0) as spend_per_bene
  FROM drug_costs
  GROUP BY state
)

SELECT 
  r.state,
  ROUND(r.state_total_drug_spend/1000000, 2) as total_drug_spend_millions,
  r.state_total_benes,
  ROUND(r.spend_per_bene, 2) as spend_per_beneficiary,
  d.hcpcs_cd as top_drug_code,
  d.hcpcs_desc as top_drug_description,
  ROUND(d.total_spend/1000000, 2) as top_drug_spend_millions
FROM state_rankings r
LEFT JOIN drug_costs d 
  ON r.state = d.state
  AND d.spend_rank = 1
WHERE r.state NOT IN ('Foreign Country', 'Unknown')
ORDER BY total_drug_spend_millions DESC
LIMIT 20;

-- How it works:
-- 1. First CTE (drug_costs) filters for drug-related services and calculates total spend
--    Also adds row_number to identify highest-spend drug per state
-- 2. Second CTE (state_rankings) aggregates spending metrics by state
-- 3. Main query joins these to show each state's total drug spend and highest-cost drug
-- 4. Results are filtered to exclude non-US locations and limited to top 20 states

-- Assumptions and Limitations:
-- 1. Assumes 2022 data is complete and representative
-- 2. Limited to Medicare Part B drug spending only
-- 3. Does not account for rebates or other price adjustments
-- 4. State-level analysis may mask important regional variations
-- 5. Only includes fee-for-service Medicare claims

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Break down by therapeutic class using HCPCS descriptions
-- 3. Compare facility vs non-facility drug utilization
-- 4. Calculate market share for specific drugs across states
-- 5. Add standardized amount analysis to control for geographic price variations
-- 6. Include beneficiary demographic factors

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:21:36.332683
    - Additional Notes: The query focuses on state-level Medicare Part B drug expenditures and identifies both total spending and highest-cost drugs per state. Note that results are limited to the top 20 states by total spend and exclude US territories. The ROW_NUMBER() approach used for identifying top drugs is more efficient than correlated subqueries for large datasets.
    
    */