-- home_health_private_equity_influence.sql
-- Analyzes the penetration and characteristics of investment firm and financial institution
-- ownership in the home health market. This helps understand private equity/financial 
-- institution involvement in healthcare delivery, which has implications for:
-- - Healthcare costs and quality
-- - Market consolidation trends
-- - Policy and regulatory considerations

WITH ownership_summary AS (
  -- Get latest ownership data per agency and categorize financial owners
  SELECT 
    organization_name,
    enrollment_id,
    COUNT(DISTINCT associate_id_owner) as total_owners,
    SUM(CASE WHEN investment_firm_owner = 'Y' OR financial_institution_owner = 'Y' THEN 1 ELSE 0 END) as financial_owners,
    MAX(CASE WHEN investment_firm_owner = 'Y' OR financial_institution_owner = 'Y' THEN percentage_ownership ELSE 0 END) as max_financial_ownership_pct,
    MAX(CASE WHEN investment_firm_owner = 'Y' OR financial_institution_owner = 'Y' THEN for_profit_owner ELSE NULL END) as is_for_profit
  FROM mimi_ws_1.datacmsgov.pc_homehealth_owner
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.pc_homehealth_owner)
  GROUP BY organization_name, enrollment_id
)

SELECT
  -- Calculate key metrics about financial ownership
  COUNT(DISTINCT enrollment_id) as total_agencies,
  COUNT(DISTINCT CASE WHEN financial_owners > 0 THEN enrollment_id END) as agencies_with_financial_owners,
  ROUND(100.0 * COUNT(DISTINCT CASE WHEN financial_owners > 0 THEN enrollment_id END) / 
    COUNT(DISTINCT enrollment_id), 2) as pct_agencies_financial_owned,
  ROUND(AVG(CASE WHEN financial_owners > 0 THEN max_financial_ownership_pct END), 2) as avg_financial_ownership_stake,
  COUNT(DISTINCT CASE WHEN financial_owners > 0 AND is_for_profit = 'Y' THEN enrollment_id END) as for_profit_financial_agencies,
  ROUND(AVG(CASE WHEN financial_owners > 0 THEN total_owners END), 2) as avg_owners_per_financial_agency
FROM ownership_summary

/* How this works:
- Creates temp table with agency-level ownership metrics
- Focuses on investment firms and financial institutions
- Calculates penetration rates and ownership characteristics
- Uses latest available data snapshot

Assumptions/Limitations:
- Relies on accurate self-reporting of owner types
- May not capture complex ownership structures
- Point-in-time analysis only
- Does not account for indirect ownership

Possible Extensions:
1. Add geographic analysis by state/region
2. Track ownership changes over time
3. Compare financial vs non-financial owned agency characteristics
4. Analyze correlation with quality metrics
5. Add size segmentation based on number of patients/revenue
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:46:36.474509
    - Additional Notes: Query focuses on investment firm and financial institution ownership patterns in home health agencies. Provides key metrics like penetration rates and ownership stakes. Best used with latest available data snapshot. May need adjustment if analyzing historical trends or specific geographic regions.
    
    */