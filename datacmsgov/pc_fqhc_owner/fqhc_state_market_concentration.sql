-- fqhc_funding_concentration.sql
--
-- Business Purpose: 
-- Analyze geographic concentration and potential funding patterns of FQHCs by examining:
-- - Regional distribution of FQHC organizations
-- - Ownership concentration by examining organizations with multiple FQHCs
-- - States with the highest FQHC presence
-- This information is valuable for:
-- - Healthcare investors and policy makers evaluating market opportunities
-- - Government agencies allocating healthcare resources
-- - Organizations planning FQHC expansion strategies

-- Main Query
WITH owner_summary AS (
  SELECT 
    state_owner,
    organization_name_owner,
    COUNT(DISTINCT enrollment_id) as num_fqhcs,
    COUNT(DISTINCT associate_id) as unique_facilities,
    AVG(CAST(percentage_ownership AS FLOAT)) as avg_ownership_pct
  FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
  WHERE organization_name_owner IS NOT NULL
    AND state_owner IS NOT NULL
  GROUP BY state_owner, organization_name_owner
),

state_metrics AS (
  SELECT
    state_owner,
    COUNT(DISTINCT organization_name_owner) as num_owner_orgs,
    SUM(num_fqhcs) as total_fqhcs,
    MAX(num_fqhcs) as max_fqhcs_per_owner
  FROM owner_summary
  GROUP BY state_owner
)

SELECT
  s.state_owner,
  s.num_owner_orgs,
  s.total_fqhcs,
  s.max_fqhcs_per_owner,
  ROUND(s.max_fqhcs_per_owner * 100.0 / s.total_fqhcs, 1) as market_concentration_pct,
  o.organization_name_owner as largest_owner
FROM state_metrics s
LEFT JOIN owner_summary o 
  ON s.state_owner = o.state_owner 
  AND s.max_fqhcs_per_owner = o.num_fqhcs
ORDER BY s.total_fqhcs DESC;

-- How it works:
-- 1. Creates owner_summary CTE to aggregate FQHC counts by owner organization and state
-- 2. Creates state_metrics CTE to calculate state-level statistics
-- 3. Joins results to identify largest owners and calculate market concentration
-- 4. Orders results by total FQHCs to highlight most significant markets

-- Assumptions and Limitations:
-- - Assumes current ownership data is accurate and complete
-- - Does not account for ownership changes over time
-- - Market concentration calculation may oversimplify complex ownership structures
-- - Some states may have incomplete data

-- Possible Extensions:
-- 1. Add year-over-year ownership change analysis
-- 2. Include demographic data to analyze FQHC distribution vs population needs
-- 3. Incorporate financial metrics to assess funding patterns
-- 4. Add geographic clustering analysis to identify potential service gaps
-- 5. Include profit status analysis to examine public/private ownership patterns/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:04:20.045530
    - Additional Notes: Query focuses on state-level market concentration of FQHC ownership, calculating both absolute numbers and percentages to identify dominant healthcare providers. The market_concentration_pct metric helps identify states where FQHC ownership may be concentrated among fewer organizations, which could have implications for healthcare access and competition.
    
    */