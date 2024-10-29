-- rhc_regional_ownership_concentration.sql

/*
Business Purpose:
- Identify geographic concentrations of RHC ownership to support:
  * Market expansion strategies for healthcare services
  * Network adequacy analysis for managed care organizations
  * Investment opportunity assessment for private equity firms
  * Regional healthcare access evaluation for policy makers

Key metrics:
- Count of RHCs by state and owner
- % of RHCs controlled by top owners in each state
- Owner organizational characteristics by region
*/

WITH owner_state_summary AS (
  -- Get unique RHC-owner combinations by state to avoid double counting
  SELECT DISTINCT
    state_owner,
    associate_id_owner,
    organization_name_owner,
    enrollment_id,
    type_owner,
    medical_provider_supplier_owner,
    management_services_company_owner,
    investment_firm_owner
  FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
  WHERE state_owner IS NOT NULL
),

state_metrics AS (
  -- Calculate ownership concentration metrics by state
  SELECT 
    state_owner,
    COUNT(DISTINCT enrollment_id) as total_rhcs,
    COUNT(DISTINCT associate_id_owner) as unique_owners,
    COUNT(DISTINCT CASE WHEN type_owner = 'O' THEN associate_id_owner END) as org_owners,
    COUNT(DISTINCT CASE WHEN medical_provider_supplier_owner = 'Y' THEN associate_id_owner END) as provider_owners,
    COUNT(DISTINCT CASE WHEN investment_firm_owner = 'Y' THEN associate_id_owner END) as pe_owners
  FROM owner_state_summary
  GROUP BY state_owner
)

SELECT 
  s.state_owner,
  s.total_rhcs,
  s.unique_owners,
  ROUND(100.0 * s.org_owners / NULLIF(s.unique_owners, 0), 1) as pct_org_owners,
  ROUND(100.0 * s.provider_owners / NULLIF(s.unique_owners, 0), 1) as pct_provider_owners,
  ROUND(100.0 * s.pe_owners / NULLIF(s.unique_owners, 0), 1) as pct_pe_owners
FROM state_metrics s
WHERE s.total_rhcs >= 5  -- Focus on states with meaningful RHC presence
ORDER BY s.total_rhcs DESC;

/*
How it works:
1. First CTE gets unique RHC-owner pairs by state to establish baseline relationships
2. Second CTE calculates key concentration metrics by state
3. Final query computes percentages and filters for meaningful state presence

Assumptions & Limitations:
- Assumes current owner data is accurate and complete
- Limited to states with 5+ RHCs to avoid skewed percentages
- Does not account for parent-subsidiary relationships
- Time dimension not considered (snapshot analysis)

Possible Extensions:
1. Add year-over-year trend analysis using mimi_src_file_date
2. Include owner role analysis (board members vs direct owners)
3. Add geographic clustering analysis within states
4. Incorporate ownership percentage weighting
5. Add managed care network adequacy overlay
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:04:37.066742
    - Additional Notes: Query focuses on state-level ownership structure of Rural Health Clinics, particularly useful for market analysis and policy planning. Minimum threshold of 5 RHCs per state helps ensure statistical relevance. Results show ownership type distribution (organizational vs individual) and investor categories (medical providers, PE firms) by state.
    
    */