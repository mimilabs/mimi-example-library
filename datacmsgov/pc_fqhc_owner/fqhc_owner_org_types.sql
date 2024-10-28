
/*******************************************************************************
Title: FQHC Owner Organization Classification Analysis
 
Business Purpose:
This query analyzes the types of organizational owners for Federally Qualified 
Health Centers (FQHCs) to understand the distribution of different organizational
structures and their potential impact on healthcare delivery.

Key metrics calculated:
- Count of FQHCs by owner organization type
- Percentage of ownership by organization type
- Average ownership stake for different organization types
*******************************************************************************/

WITH owner_types AS (
  -- Pivot the organization type flags into a single category per owner
  SELECT
    associate_id,
    organization_name,
    associate_id_owner,
    CASE
      WHEN corporation_owner = 'Y' THEN 'Corporation'
      WHEN llc_owner = 'Y' THEN 'LLC' 
      WHEN medical_provider_supplier_owner = 'Y' THEN 'Medical Provider'
      WHEN management_services_company_owner = 'Y' THEN 'Management Services'
      WHEN medical_staffing_company_owner = 'Y' THEN 'Medical Staffing'
      WHEN holding_company_owner = 'Y' THEN 'Holding Company'
      WHEN investment_firm_owner = 'Y' THEN 'Investment Firm'
      WHEN financial_institution_owner = 'Y' THEN 'Financial Institution'
      WHEN consulting_firm_owner = 'Y' THEN 'Consulting Firm'
      ELSE 'Other'
    END AS owner_category,
    percentage_ownership,
    type_owner
  FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
  WHERE type_owner = 'O' -- Focus on organizational owners only
)

SELECT
  owner_category,
  COUNT(DISTINCT associate_id) as num_fqhcs,
  COUNT(DISTINCT associate_id_owner) as num_unique_owners,
  ROUND(AVG(percentage_ownership),2) as avg_ownership_percentage,
  ROUND(MIN(percentage_ownership),2) as min_ownership_percentage,
  ROUND(MAX(percentage_ownership),2) as max_ownership_percentage
FROM owner_types
GROUP BY owner_category
HAVING COUNT(DISTINCT associate_id) > 0
ORDER BY num_fqhcs DESC;

/*******************************************************************************
How this query works:
1. Creates a CTE to classify organizational owners into distinct categories
2. Aggregates key metrics by owner category to show ownership patterns
3. Filters for meaningful results and sorts by number of FQHCs

Assumptions and Limitations:
- Only considers organizational owners (type_owner = 'O')
- Owner categories are mutually exclusive based on first matching flag
- Ownership percentages are assumed to be accurate as reported

Possible Extensions:
1. Add geographic analysis by joining with location data
2. Compare ownership patterns between for-profit vs non-profit owners
3. Analyze changes in ownership structure over time using mimi_src_file_date
4. Examine correlation between owner types and FQHC performance metrics
5. Include individual owner analysis for complete ownership picture
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:25:08.788515
    - Additional Notes: Query focuses on organizational ownership classification and excludes individual owners. Results are aggregated at the owner category level, showing key metrics like average ownership percentage and number of FQHCs per owner type. Best used for understanding the distribution and concentration of institutional control across the FQHC network.
    
    */