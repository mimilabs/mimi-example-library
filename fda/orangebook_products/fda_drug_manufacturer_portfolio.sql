
/*************************************************************************
FDA Orange Book Drug Product Analysis - Core Business Value Query
************************************************************************* 

Business Purpose:
- Analyze FDA approved drug products to understand market trends and therapeutic options
- Identify key manufacturers and their drug portfolios
- Monitor prescription vs OTC drug distribution
- Track approval patterns over time

Created: 2024
*/

-- Main analysis - Drug market overview by manufacturer and type
WITH applicant_stats AS (
  SELECT 
    applicant,
    type,
    COUNT(DISTINCT trade_name) as num_drugs,
    COUNT(DISTINCT ingredient) as num_ingredients,
    MIN(approval_date) as earliest_approval,
    MAX(approval_date) as latest_approval
  FROM mimi_ws_1.fda.orangebook_products
  WHERE approval_date IS NOT NULL
  GROUP BY applicant, type
)

SELECT
  applicant,
  type,
  num_drugs,
  num_ingredients,
  earliest_approval,
  latest_approval,
  -- Calculate years active in market
  DATEDIFF(year, earliest_approval, latest_approval) as years_active,
  -- Calculate drugs per year rate
  ROUND(num_drugs::FLOAT / NULLIF(DATEDIFF(year, earliest_approval, latest_approval),0), 2) as drugs_per_year
FROM applicant_stats
WHERE num_drugs >= 5  -- Focus on major manufacturers
ORDER BY num_drugs DESC
LIMIT 20;

/*
How this query works:
1. Creates a CTE to aggregate statistics by manufacturer and drug type
2. Calculates key metrics like number of drugs, ingredients, approval dates
3. Derives additional metrics like years active and approval rate
4. Filters to significant manufacturers and sorts by portfolio size

Key Assumptions & Limitations:
- Assumes approval_date is reliable indicator of market presence
- Limited to top 20 manufacturers by number of drugs
- Does not account for discontinued products
- Portfolio size may not correlate with market share/revenue

Possible Extensions:
1. Add therapeutic category analysis:
   - Group by ingredient categories
   - Compare prescription vs OTC distribution
   
2. Add time-based trends:
   - Approval rates by year
   - Seasonal patterns
   - Market entry/exit analysis
   
3. Add competitive analysis:
   - Overlapping ingredients between manufacturers
   - Generic vs brand name competition
   - Therapeutic equivalence patterns

4. Add regulatory insights:
   - Application type distributions
   - Approval timeline analysis
   - Reference drug patterns
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:06:35.248368
    - Additional Notes: Query focuses on manufacturers with 5+ drugs and requires non-null approval dates. Results ordered by portfolio size (number of distinct drugs) and limited to top 20 manufacturers. The drugs_per_year calculation may show infinity/null for manufacturers with only one approval date.
    
    */