
/* 
NADAC Generic vs Brand Price Comparison Analysis

Business Purpose:
This query analyzes the price differential between brand and generic drugs to:
1. Identify potential cost savings opportunities from generic alternatives
2. Support formulary decision-making 
3. Help understand pricing trends for brand-generic pairs

The analysis focuses on drugs that have both brand and generic versions available
to enable direct comparisons of their acquisition costs.
*/

WITH brand_generic_pairs AS (
  -- Get brand drugs with generic alternatives
  SELECT DISTINCT
    ndc_description,
    nadac_per_unit as brand_nadac,
    corresponding_generic_drug_nadac_per_unit as generic_nadac,
    effective_date,
    pricing_unit,
    -- Calculate price differential
    (nadac_per_unit - corresponding_generic_drug_nadac_per_unit) as price_diff,
    -- Calculate percentage savings
    ROUND(((nadac_per_unit - corresponding_generic_drug_nadac_per_unit) / nadac_per_unit * 100), 1) as savings_pct
  FROM mimi_ws_1.datamedicaidgov.nadac
  WHERE classification_for_rate_setting = 'B' -- Brand drugs only
    AND corresponding_generic_drug_nadac_per_unit IS NOT NULL -- Must have generic alternative
    AND effective_date >= DATE_SUB(CURRENT_DATE(), 30) -- Last 30 days
    AND nadac_per_unit > 0 -- Valid prices only
)

SELECT
  ndc_description,
  pricing_unit,
  ROUND(brand_nadac, 2) as brand_price,
  ROUND(generic_nadac, 2) as generic_price, 
  ROUND(price_diff, 2) as absolute_savings,
  savings_pct as percent_savings,
  effective_date
FROM brand_generic_pairs
WHERE savings_pct > 50 -- Focus on drugs with significant savings potential
ORDER BY savings_pct DESC
LIMIT 20;

/*
How it works:
1. Creates a CTE to identify brand drugs with generic alternatives
2. Calculates price differences and potential savings percentages
3. Filters for significant savings opportunities (>50%)
4. Returns top 20 drugs ranked by savings potential

Assumptions & Limitations:
- Focuses only on brand drugs with existing generic alternatives
- Uses most recent 30 days of pricing data
- Does not account for rebates or discounts
- Assumes pricing units are comparable between brand/generic versions
- Does not consider clinical equivalency or substitution restrictions

Possible Extensions:
1. Add trending analysis to show how price gaps change over time
2. Include volume/utilization data to calculate total savings impact
3. Group by therapeutic class to identify categories with highest savings
4. Add filters for specific dosage forms or routes of administration
5. Calculate weighted averages based on prescription volumes
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:24:33.753840
    - Additional Notes: Query identifies cost-saving opportunities by comparing brand vs generic drug prices in the last 30 days, focusing on medications with >50% potential savings. Best used for formulary management and cost containment initiatives. Note that savings calculations do not account for manufacturer rebates or volume-based discounts.
    
    */