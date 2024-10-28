
/*******************************************************************************
Title: FQHC Ownership Analysis - Key Metrics
 
Business Purpose:
This query analyzes the ownership structure of Federally Qualified Health Centers
(FQHCs) to provide insights into:
- Distribution of individual vs organizational ownership
- Average ownership percentages
- Types of organizational owners
- Geographic distribution of ownership

This information helps understand FQHC governance patterns and can inform
policy decisions around healthcare access and management.
*******************************************************************************/

WITH ownership_summary AS (
  -- Calculate key metrics per FQHC
  SELECT 
    organization_name as fqhc_name,
    state_owner,
    COUNT(DISTINCT associate_id_owner) as total_owners,
    COUNT(DISTINCT CASE WHEN type_owner = 'I' THEN associate_id_owner END) as individual_owners,
    COUNT(DISTINCT CASE WHEN type_owner = 'O' THEN associate_id_owner END) as org_owners,
    AVG(percentage_ownership) as avg_ownership_pct,
    SUM(CASE WHEN non_profit_owner = 'Y' THEN 1 ELSE 0 END) as nonprofit_owners,
    SUM(CASE WHEN for_profit_owner = 'Y' THEN 1 ELSE 0 END) as forprofit_owners
  FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
  GROUP BY organization_name, state_owner
)

SELECT
  -- High-level ownership statistics
  COUNT(*) as total_fqhcs,
  AVG(total_owners) as avg_owners_per_fqhc,
  AVG(individual_owners) as avg_individual_owners,
  AVG(org_owners) as avg_org_owners,
  AVG(avg_ownership_pct) as overall_avg_ownership_pct,
  
  -- Ownership type distribution
  SUM(nonprofit_owners) as total_nonprofit_owners,
  SUM(forprofit_owners) as total_forprofit_owners,
  
  -- Geographic diversity
  COUNT(DISTINCT state_owner) as states_represented

FROM ownership_summary;

/*******************************************************************************
How This Query Works:
1. Creates a CTE to summarize ownership metrics per FQHC
2. Aggregates the data to provide high-level insights about ownership patterns
3. Includes both numerical and categorical analysis

Assumptions & Limitations:
- Assumes data completeness in key fields
- Does not account for changes over time
- May include FQHCs with incomplete ownership records
- Geographic analysis limited to state level

Possible Extensions:
1. Add time-based analysis using association_date_owner
2. Include detailed breakdowns of owner roles using role_code_owner
3. Analyze specific organization types (LLC, corporation, etc.)
4. Add regional groupings for geographic analysis 
5. Calculate ownership concentration metrics
6. Compare urban vs rural ownership patterns
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T13:54:24.118769
    - Additional Notes: Query aggregates ownership patterns across all FQHCs but may show incomplete results if ownership data is missing or if percentage_ownership values are not consistently reported. Consider adding data quality checks before using results for critical analysis.
    
    */