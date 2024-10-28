
/*******************************************************************************
Title: Medicare Part D Drug Coverage Restrictions Analysis
 
Business Purpose:
This query analyzes prescription drug coverage restrictions and tier pricing 
across Medicare Part D formularies to:
1. Identify drugs with high restriction rates
2. Compare accessibility across tier levels
3. Help understand barriers to prescription drug access

Key business value:
- Informs policy decisions around drug coverage
- Highlights potential access barriers for beneficiaries
- Enables comparisons of formulary designs across plans
*******************************************************************************/

-- Main analysis of drug coverage restrictions by tier level
WITH drug_stats AS (
  SELECT 
    rxcui,
    tier_level_value,
    COUNT(*) as total_occurrences,
    
    -- Calculate restriction rates
    SUM(CASE WHEN prior_authorization_yn = 'Y' THEN 1 ELSE 0 END) as pa_count,
    SUM(CASE WHEN quantity_limit_yn = 'Y' THEN 1 ELSE 0 END) as ql_count,
    SUM(CASE WHEN step_therapy_yn = 'Y' THEN 1 ELSE 0 END) as st_count
  FROM mimi_ws_1.prescriptiondrugplan.basic_drugs_formulary
  WHERE contract_year = 2024  -- Focus on current year
  GROUP BY rxcui, tier_level_value
)

SELECT
  rxcui,
  tier_level_value,
  total_occurrences,
  
  -- Calculate restriction percentages
  ROUND(pa_count * 100.0 / total_occurrences, 1) as prior_auth_pct,
  ROUND(ql_count * 100.0 / total_occurrences, 1) as quantity_limit_pct,
  ROUND(st_count * 100.0 / total_occurrences, 1) as step_therapy_pct,
  
  -- Calculate combined restriction score
  ROUND((pa_count + ql_count + st_count) * 100.0 / (total_occurrences * 3), 1) 
    as overall_restriction_score
FROM drug_stats
WHERE total_occurrences >= 100  -- Focus on commonly included drugs
ORDER BY overall_restriction_score DESC, total_occurrences DESC
LIMIT 100;

/*******************************************************************************
How this query works:
1. Groups drugs by RxCUI and tier level
2. Calculates frequency of each restriction type
3. Computes percentage rates and overall restriction score
4. Filters to focus on commonly included drugs
5. Orders results by restriction level and frequency

Assumptions and limitations:
- Focuses on current contract year only
- Assumes Y/N indicators are consistently populated
- May not capture nuanced restriction combinations
- Minimum threshold of 100 occurrences may exclude some relevant drugs

Possible extensions:
1. Add trend analysis across contract years
2. Join with drug name/category information for better context
3. Compare restriction patterns across different formulary IDs
4. Add geographic analysis by joining with plan information
5. Analyze restriction patterns by drug class or therapeutic category
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:28:03.198707
    - Additional Notes: This query only analyzes drugs with 100+ occurrences across formularies, which provides statistical significance but may exclude specialty medications. The 'overall_restriction_score' is a simplified metric that gives equal weight to all restriction types (PA, QL, ST) and may need adjustment based on specific business needs. Consider joining with RxNorm data for drug names and therapeutic classifications for more meaningful analysis.
    
    */