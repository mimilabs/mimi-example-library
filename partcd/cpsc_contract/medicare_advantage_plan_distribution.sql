
/* Medicare Advantage Contract Analysis - Core Business Insights
 * 
 * Business Purpose:
 * This query provides key insights into the Medicare Advantage market by analyzing:
 * 1. Distribution of plan types and their Part D coverage offerings
 * 2. Market share of different organization types
 * 3. Special Needs Plan (SNP) availability
 * Using the most recent data snapshot to support strategic planning and market analysis
 */

WITH latest_snapshot AS (
  -- Get the most recent data snapshot
  SELECT MAX(mimi_src_file_date) as max_date 
  FROM mimi_ws_1.partcd.cpsc_contract
)

SELECT 
  -- Plan type distribution and Part D coverage
  plan_type,
  organization_type,
  COUNT(DISTINCT contract_id) as contract_count,
  COUNT(DISTINCT CASE WHEN offers_part_d = TRUE THEN contract_id END) as contracts_with_part_d,
  ROUND(COUNT(DISTINCT CASE WHEN offers_part_d = TRUE THEN contract_id END) * 100.0 / 
        COUNT(DISTINCT contract_id), 1) as pct_with_part_d,
  
  -- SNP availability
  COUNT(DISTINCT CASE WHEN snp_plan = TRUE THEN contract_id END) as snp_contracts,
  ROUND(COUNT(DISTINCT CASE WHEN snp_plan = TRUE THEN contract_id END) * 100.0 / 
        COUNT(DISTINCT contract_id), 1) as pct_snp

FROM mimi_ws_1.partcd.cpsc_contract c
JOIN latest_snapshot ls
  ON c.mimi_src_file_date = ls.max_date

GROUP BY 
  plan_type,
  organization_type

ORDER BY 
  contract_count DESC,
  plan_type,
  organization_type;

/* How this query works:
 * 1. Uses CTE to identify most recent data snapshot
 * 2. Aggregates contracts by plan and organization type
 * 3. Calculates Part D coverage and SNP percentages
 * 4. Orders results by market presence (contract count)
 *
 * Assumptions & Limitations:
 * - Uses latest snapshot only - historical trends not included
 * - Treats each contract equally regardless of enrollment size
 * - Does not account for geographic distribution
 *
 * Possible Extensions:
 * 1. Add geographic analysis by joining with county-level data
 * 2. Include trend analysis by comparing multiple time periods
 * 3. Add parent organization analysis to show market concentration
 * 4. Include enrollment data to weight market share calculations
 * 5. Add filters for specific regions or organization types
 */
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:25:58.892644
    - Additional Notes: Query focuses on current market structure of Medicare Advantage plans using latest data snapshot. Results show distribution of plan types, Part D coverage rates, and SNP availability. For historical analysis or geographic distribution, query will need to be modified.
    
    */