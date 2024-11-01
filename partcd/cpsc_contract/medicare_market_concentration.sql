-- Medicare Advantage Market Concentration Analysis
-- Business Purpose:
--   This analysis examines market concentration and parent organization dominance
--   in the Medicare Advantage space to:
--   1. Identify market leaders and their share of total contracts
--   2. Analyze diversification of plan offerings by major parent organizations
--   3. Help assess competitive dynamics and market power

-- Main Query
WITH parent_metrics AS (
  -- Calculate metrics by parent organization
  SELECT 
    parent_organization,
    COUNT(DISTINCT contract_id) as contract_count,
    COUNT(DISTINCT plan_id) as plan_count,
    COUNT(DISTINCT CASE WHEN snp_plan = true THEN plan_id END) as snp_plan_count,
    COUNT(DISTINCT organization_marketing_name) as brand_count
  FROM mimi_ws_1.partcd.cpsc_contract
  WHERE parent_organization IS NOT NULL 
  AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.partcd.cpsc_contract)
  GROUP BY parent_organization
),
total_contracts AS (
  -- Get total contract count for market share calculation
  SELECT COUNT(DISTINCT contract_id) as total_contracts
  FROM mimi_ws_1.partcd.cpsc_contract
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.partcd.cpsc_contract)
)

SELECT 
  pm.parent_organization,
  pm.contract_count,
  pm.plan_count,
  pm.snp_plan_count,
  pm.brand_count,
  ROUND(100.0 * pm.contract_count / tc.total_contracts, 1) as market_share_pct,
  ROUND(1.0 * pm.plan_count / pm.contract_count, 1) as plans_per_contract
FROM parent_metrics pm
CROSS JOIN total_contracts tc
WHERE pm.contract_count >= 5  -- Focus on significant players
ORDER BY pm.contract_count DESC
LIMIT 20

-- Query Operation:
--   1. Creates temp table with key metrics by parent organization
--   2. Calculates total contract count for market share
--   3. Joins and computes final metrics for top 20 organizations
--   4. Filters to organizations with 5+ contracts to focus on major players

-- Assumptions and Limitations:
--   - Uses parent_organization as primary grouping level
--   - Assumes current snapshot (latest mimi_src_file_date)
--   - Market share based on contract count, not enrollment
--   - Organizations with null parent_organization excluded
--   - Limited to top 20 organizations by contract count

-- Possible Extensions:
--   1. Add year-over-year comparison of market share changes
--   2. Include geographic concentration analysis
--   3. Add contract value/revenue metrics if available
--   4. Segment analysis by organization_type
--   5. Add risk scoring based on market concentration metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:07:34.124065
    - Additional Notes: Query focuses on parent organization level metrics and requires at least 5 contracts per organization for inclusion. Market share calculations are based on contract counts rather than enrollment numbers, which may not fully represent actual market dominance. Organizations without parent organization data are excluded from analysis.
    
    */