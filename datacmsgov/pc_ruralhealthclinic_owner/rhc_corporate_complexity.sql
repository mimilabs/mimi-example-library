-- rhc_corporate_structure_analysis.sql

-- Business Purpose:
-- Analyze the corporate structure and organizational composition of RHC owners to understand:
--   - Types of corporate entities controlling RHCs
--   - Prevalence of complex ownership structures (e.g., holding companies, management services)
--   - Distribution of ownership models across different business structures
-- This information helps:
--   - Healthcare investors evaluate market entry strategies
--   - Policymakers assess corporate consolidation in rural healthcare
--   - Health systems benchmark their organizational models

-- Main Query
WITH owner_type_summary AS (
  -- First aggregate ownership types and corporate structures
  SELECT 
    organization_name,
    COUNT(DISTINCT associate_id_owner) as num_owners,
    SUM(CASE WHEN corporation_owner = 'Y' THEN 1 ELSE 0 END) as num_corporate_owners,
    SUM(CASE WHEN llc_owner = 'Y' THEN 1 ELSE 0 END) as num_llc_owners,
    SUM(CASE WHEN holding_company_owner = 'Y' THEN 1 ELSE 0 END) as num_holding_company,
    SUM(CASE WHEN management_services_company_owner = 'Y' THEN 1 ELSE 0 END) as num_mgmt_services,
    AVG(CAST(percentage_ownership AS FLOAT)) as avg_ownership_pct
  FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
  WHERE type_owner = 'O' -- Focus on organizational owners
  GROUP BY organization_name
)

SELECT 
  -- Categorize ownership complexity
  CASE 
    WHEN num_owners = 1 THEN 'Single Owner'
    WHEN num_owners <= 3 THEN '2-3 Owners'
    ELSE 'Complex Structure (4+ Owners)'
  END as ownership_structure,
  
  -- Calculate statistics
  COUNT(*) as num_rhcs,
  ROUND(AVG(avg_ownership_pct), 1) as avg_ownership_percentage,
  ROUND(AVG(num_corporate_owners * 100.0 / num_owners), 1) as pct_corporate_owners,
  ROUND(AVG(num_llc_owners * 100.0 / num_owners), 1) as pct_llc_owners,
  SUM(CASE WHEN num_holding_company > 0 THEN 1 ELSE 0 END) as has_holding_company,
  SUM(CASE WHEN num_mgmt_services > 0 THEN 1 ELSE 0 END) as has_mgmt_services

FROM owner_type_summary
GROUP BY 
  CASE 
    WHEN num_owners = 1 THEN 'Single Owner'
    WHEN num_owners <= 3 THEN '2-3 Owners'
    ELSE 'Complex Structure (4+ Owners)'
  END
ORDER BY num_rhcs DESC;

-- How this query works:
-- 1. Creates a CTE that summarizes ownership types and structures for each RHC
-- 2. Categorizes RHCs by ownership complexity (single, 2-3, or 4+ owners)
-- 3. Calculates key metrics about corporate structure and ownership concentration
-- 4. Groups results by ownership complexity category

-- Assumptions and Limitations:
-- - Focuses only on organizational owners (type_owner = 'O')
-- - Assumes percentage_ownership field is populated and accurate
-- - Does not account for temporal changes in ownership
-- - May not capture all nuances of complex corporate structures

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in corporate structure over time
-- 2. Include geographic analysis to identify regional patterns
-- 3. Add filters for specific owner types or ownership percentages
-- 4. Incorporate individual owner analysis for hybrid ownership models
-- 5. Add correlation analysis with RHC performance metrics if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:07:19.600590
    - Additional Notes: Query groups RHCs by ownership complexity and provides key corporate structure metrics including ownership percentages and management types. Best used for initial assessment of organizational ownership patterns. Note that results may be skewed for RHCs with incomplete ownership percentage data.
    
    */