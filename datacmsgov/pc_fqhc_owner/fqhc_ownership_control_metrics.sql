-- fqhc_owner_financial_analysis.sql

-- Business Purpose: 
-- Analyze the financial ownership characteristics of FQHCs by examining:
-- 1. The percentage ownership distribution across different owner types
-- 2. Total ownership stake for each FQHC to identify potential control concerns
-- 3. Identify FQHCs where ownership structure may impact financial oversight

WITH owner_summary AS (
  -- Calculate ownership percentages by FQHC
  SELECT 
    organization_name,
    enrollment_id,
    COUNT(DISTINCT associate_id_owner) as total_owners,
    SUM(CASE WHEN type_owner = 'I' THEN percentage_ownership ELSE 0 END) as individual_ownership_pct,
    SUM(CASE WHEN type_owner = 'O' THEN percentage_ownership ELSE 0 END) as org_ownership_pct,
    SUM(percentage_ownership) as total_ownership_pct,
    MAX(percentage_ownership) as max_single_owner_pct
  FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
  WHERE percentage_ownership IS NOT NULL
  GROUP BY organization_name, enrollment_id
)

SELECT
  organization_name,
  total_owners,
  ROUND(individual_ownership_pct,1) as individual_ownership_pct,
  ROUND(org_ownership_pct,1) as org_ownership_pct,
  ROUND(total_ownership_pct,1) as total_ownership_pct,
  ROUND(max_single_owner_pct,1) as max_single_owner_pct,
  CASE 
    WHEN total_ownership_pct < 100 THEN 'Incomplete Ownership'
    WHEN total_ownership_pct > 100 THEN 'Over-reported Ownership'
    ELSE 'Complete Ownership'
  END as ownership_status,
  CASE
    WHEN max_single_owner_pct >= 50 THEN 'Majority Control'
    WHEN max_single_owner_pct >= 25 THEN 'Significant Influence'
    ELSE 'Distributed Control'
  END as control_classification
FROM owner_summary
WHERE total_ownership_pct > 0
ORDER BY total_ownership_pct DESC, total_owners DESC

-- How it works:
-- 1. Creates a CTE to aggregate ownership percentages by FQHC
-- 2. Calculates key metrics including total owners and ownership distribution
-- 3. Classifies ownership completeness and control patterns
-- 4. Returns sorted results focusing on ownership concentration

-- Assumptions and Limitations:
-- 1. Assumes percentage_ownership field is accurately reported
-- 2. Does not account for indirect ownership through multiple entities
-- 3. May not capture all nuances of complex ownership structures
-- 4. Limited to explicit ownership percentages (nulls excluded)

-- Possible Extensions:
-- 1. Add trending analysis to track ownership changes over time
-- 2. Include geographic analysis of ownership patterns
-- 3. Incorporate role_code_owner to analyze management control
-- 4. Add filters for specific ownership thresholds of interest
-- 5. Include additional risk factors based on owner characteristics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:05:09.722942
    - Additional Notes: Query focuses on ownership control patterns and completeness of ownership reporting. The max_single_owner_pct calculation is particularly useful for identifying concentration of control. Note that the 50% and 25% thresholds for control classification are based on common regulatory frameworks but may need adjustment for specific analysis needs.
    
    */