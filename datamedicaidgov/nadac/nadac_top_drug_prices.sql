
/* 
Title: Core NADAC Drug Pricing Analysis

Business Purpose:
This query analyzes the National Average Drug Acquisition Cost (NADAC) data to:
1. Track drug pricing trends over time
2. Compare brand vs generic pricing
3. Identify high-cost medications
4. Monitor price changes for frequently used drugs

This information helps stakeholders understand drug cost patterns and supports
pharmacy reimbursement decisions.
*/

WITH recent_prices AS (
  -- Get most recent prices for each drug to focus on current costs
  SELECT 
    ndc_description,
    ndc,
    nadac_per_unit,
    effective_date,
    pricing_unit,
    classification_for_rate_setting,
    otc
  FROM mimi_ws_1.datamedicaidgov.nadac
  WHERE effective_date = (
    SELECT MAX(effective_date) 
    FROM mimi_ws_1.datamedicaidgov.nadac
  )
)

SELECT
  -- Basic drug info
  ndc_description,
  classification_for_rate_setting as drug_type,
  pricing_unit,
  otc as is_otc,
  
  -- Price metrics
  ROUND(nadac_per_unit, 2) as current_price_per_unit,
  
  -- Categorize price points
  CASE 
    WHEN nadac_per_unit >= 100 THEN 'High Cost'
    WHEN nadac_per_unit >= 10 THEN 'Medium Cost' 
    ELSE 'Low Cost'
  END as price_category

FROM recent_prices

-- Focus on most expensive drugs first
WHERE nadac_per_unit > 0
ORDER BY nadac_per_unit DESC
LIMIT 100;

/*
How this query works:
1. CTE gets the most recent pricing data for each drug
2. Main query extracts key drug details and pricing information
3. Results are categorized by price level and sorted by unit cost
4. Limited to top 100 records for initial analysis

Assumptions & Limitations:
- Uses most recent pricing only - historical trends not shown
- Price categories are arbitrarily defined
- Does not account for typical prescription quantities
- Excludes zero/null prices

Possible Extensions:
1. Add year-over-year price change analysis
2. Group by therapeutic class
3. Compare brand vs generic price differences
4. Calculate average prices by drug type
5. Add filters for specific drug classes or price ranges
6. Incorporate prescription volume data if available
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T13:53:32.383259
    - Additional Notes: This query focuses on current drug pricing tiers from NADAC data, providing insights into high-cost medications. Note that the price tier thresholds ($100 and $10) may need adjustment based on specific analysis needs. The 100-row limit should be modified based on actual reporting requirements.
    
    */