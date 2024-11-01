-- rhc_private_equity_ownership_analysis.sql

-- Business Purpose:
-- Analyze private equity and investment firm presence in Rural Health Clinics (RHCs) to understand:
--   - Extent of private equity/investment firm ownership 
--   - Geographic concentration of PE-owned facilities
--   - Comparison with other ownership types
--   This analysis can inform policy discussions and market dynamics assessment

-- Main Query
WITH pe_ownership AS (
  SELECT 
    organization_name,
    state_owner,
    COUNT(DISTINCT enrollment_id) as clinic_count,
    SUM(CASE WHEN investment_firm_owner = 'Y' OR holding_company_owner = 'Y' THEN 1 ELSE 0 END) as pe_owned_count,
    AVG(CAST(percentage_ownership AS FLOAT)) as avg_ownership_pct,
    MAX(CAST(percentage_ownership AS FLOAT)) as max_ownership_pct
  FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
  WHERE type_owner = 'O' -- Focus on organizational owners
  GROUP BY organization_name, state_owner
),
state_summary AS (
  SELECT 
    state_owner,
    COUNT(DISTINCT organization_name) as total_orgs,
    SUM(pe_owned_count) as total_pe_clinics,
    SUM(clinic_count) as total_clinics,
    ROUND(AVG(avg_ownership_pct),2) as avg_ownership_pct
  FROM pe_ownership
  GROUP BY state_owner
)

SELECT 
  state_owner as state,
  total_orgs,
  total_pe_clinics,
  total_clinics,
  ROUND(100.0 * total_pe_clinics / NULLIF(total_clinics, 0), 2) as pe_penetration_pct,
  avg_ownership_pct
FROM state_summary
WHERE state_owner IS NOT NULL
ORDER BY total_pe_clinics DESC, state_owner;

-- How it works:
-- 1. First CTE (pe_ownership) aggregates clinic-level ownership data
-- 2. Second CTE (state_summary) rolls up to state-level metrics
-- 3. Final query calculates PE penetration percentage and formats output

-- Assumptions & Limitations:
-- - Assumes investment_firm_owner and holding_company_owner flags accurately identify PE ownership
-- - Does not account for indirect PE ownership through management companies
-- - May undercount PE presence if ownership is through shell companies
-- - Limited to explicitly reported ownership relationships

-- Possible Extensions:
-- 1. Add temporal analysis to track PE ownership trends over time
-- 2. Include additional owner characteristics (e.g., for_profit_owner)
-- 3. Cross-reference with clinic performance or quality metrics
-- 4. Add geographic clustering analysis for PE-owned facilities
-- 5. Compare ownership percentages between PE and non-PE owners

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:05:25.050742
    - Additional Notes: Query focuses on quantifying private equity ownership in rural health clinics by state. Results show penetration rates and average ownership percentages, which can be critical for understanding market consolidation patterns. Note that results may underestimate PE presence due to complex ownership structures and indirect holdings.
    
    */