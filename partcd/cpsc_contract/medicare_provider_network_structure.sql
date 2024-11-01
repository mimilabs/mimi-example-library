-- Medicare Advantage Provider Network Analysis
-- Business Purpose:
--   This analysis examines the provider organization landscape to understand:
--   1. The diversity of healthcare delivery models (org types and plan structures)
--   2. Strategic relationships between parent orgs and operating entities
--   3. Market entry patterns based on contract effective dates
--   Key stakeholders: Network Strategy, Provider Relations, Market Intelligence teams

WITH current_contracts AS (
  -- Get the most recent snapshot of contract data
  SELECT *,
         row_number() OVER (PARTITION BY contract_id, plan_id 
                           ORDER BY mimi_src_file_date DESC) as rn
  FROM mimi_ws_1.partcd.cpsc_contract
),

provider_summary AS (
  -- Analyze provider organization structure
  SELECT 
    organization_type,
    parent_organization,
    COUNT(DISTINCT contract_id) as num_contracts,
    COUNT(DISTINCT plan_id) as num_plans,
    COUNT(DISTINCT organization_name) as num_operating_entities,
    MIN(contract_effective_date) as earliest_entry,
    MAX(contract_effective_date) as latest_entry
  FROM current_contracts 
  WHERE rn = 1
  GROUP BY organization_type, parent_organization
)

SELECT
  organization_type,
  parent_organization,
  num_contracts,
  num_plans,
  num_operating_entities,
  earliest_entry,
  latest_entry,
  -- Calculate average plans per contract
  ROUND(CAST(num_plans AS FLOAT)/CAST(num_contracts AS FLOAT),2) as plans_per_contract,
  -- Calculate market presence duration in years
  ROUND(DATEDIFF(year, earliest_entry, latest_entry),1) as years_in_market
FROM provider_summary
WHERE parent_organization IS NOT NULL
ORDER BY num_contracts DESC, num_plans DESC
LIMIT 25;

-- How this query works:
-- 1. Creates a CTE to get the latest data snapshot
-- 2. Aggregates provider organization metrics
-- 3. Calculates operational efficiency and market presence metrics
-- 4. Filters and ranks results by market presence

-- Assumptions and Limitations:
-- - Parent organization field is populated and accurate
-- - Contract effective dates represent true market entry
-- - Analysis excludes organizations without parent org data
-- - Historical contract terminations not captured

-- Possible Extensions:
-- 1. Add geographic analysis by joining with state/county tables
-- 2. Include SNP and EGHP segmentation analysis
-- 3. Analyze organization name vs marketing name patterns
-- 4. Track consolidation patterns through parent org changes
-- 5. Compare traditional vs innovative delivery models

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:09:51.111466
    - Additional Notes: Query focuses on organizational hierarchies and operational scale within Medicare Advantage networks. May need performance optimization for datasets spanning multiple years due to the window function in the first CTE. Consider adding indexes on contract_id, plan_id, and mimi_src_file_date if query performance becomes an issue.
    
    */