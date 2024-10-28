
/*******************************************************************************
Title: Medicare Plan Cost Analysis by Type and Region
 
Business Purpose:
- Analyze Medicare prescription drug plan costs and distribution across regions
- Help identify cost variations and access patterns for beneficiaries
- Support decision-making around plan offerings and pricing strategies

Key metrics:
- Average premiums and deductibles by plan type and region
- Plan counts and distribution
- Special needs plan availability
*******************************************************************************/

WITH plan_types AS (
  -- Categorize plans based on contract_id prefix
  SELECT 
    CASE 
      WHEN LEFT(contract_id, 1) = 'H' THEN 'Local MA Plan'
      WHEN LEFT(contract_id, 1) = 'R' THEN 'Regional MA Plan' 
      WHEN LEFT(contract_id, 1) = 'S' THEN 'Standalone PDP'
    END as plan_type,
    *
  FROM mimi_ws_1.prescriptiondrugplan.plan_information
)

SELECT
  -- Plan type and region summary
  plan_type,
  COALESCE(ma_region_code, pdp_region_code) as region_code,
  
  -- Plan counts and costs
  COUNT(DISTINCT contract_id) as num_contracts,
  COUNT(DISTINCT plan_id) as num_plans,
  
  -- Cost metrics
  ROUND(AVG(premium), 2) as avg_monthly_premium,
  ROUND(AVG(deductible), 2) as avg_annual_deductible,
  
  -- Special needs plan distribution
  SUM(CASE WHEN snp > 0 THEN 1 ELSE 0 END) as snp_plan_count,
  
  -- Data currency
  MAX(mimi_src_file_date) as data_as_of

FROM plan_types
WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                           FROM mimi_ws_1.prescriptiondrugplan.plan_information)
  AND plan_suppressed_yn = 'N'
  
GROUP BY 
  plan_type,
  COALESCE(ma_region_code, pdp_region_code)

HAVING num_plans >= 1

ORDER BY 
  plan_type,
  region_code;

/*******************************************************************************
How this query works:
1. Creates plan type categories based on contract_id prefix
2. Aggregates key metrics by plan type and region
3. Filters for most recent data and non-suppressed plans
4. Shows distribution of regular vs special needs plans

Assumptions and Limitations:
- Uses most recent data snapshot only
- Combines MA and PDP regions (though they're different geographic areas)
- Excludes suppressed plans
- Averages may mask significant variation within categories

Possible Extensions:
1. Add year-over-year cost trend analysis
2. Break out SNP types (Chronic, Dual, Institutional)
3. Include geographic analysis at county level for local MA plans
4. Add formulary coverage metrics by linking to other tables
5. Analyze relationship between premiums and deductibles
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:46:07.975789
    - Additional Notes: Query assumes MA_region_code and PDP_region_code can be meaningfully combined using COALESCE, which may not be geographically accurate. For more precise regional analysis, consider separate queries for MA plans vs PDPs. Monthly premium averages do not account for plan enrollment numbers, so results represent unweighted plan averages rather than beneficiary experience.
    
    */