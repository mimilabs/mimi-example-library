-- therapeutic_area_research_investments.sql

/*
BUSINESS PURPOSE:
This analysis reveals pharmaceutical and medical device companies' research investment 
patterns across different therapeutic areas. Understanding where research dollars are 
being directed helps identify:
- Industry priorities in medical research
- Emerging therapeutic focus areas
- Potential gaps in research funding
- Strategic research investment trends

The insights support decisions around:
- Research partnership opportunities
- Market entry strategies
- Portfolio planning
- Investment prioritization
*/

-- Main Query
WITH research_by_therapeutic_area AS (
  SELECT 
    product_category_or_therapeutic_area_1 as therapeutic_area,
    program_year,
    COUNT(DISTINCT record_id) as num_studies,
    COUNT(DISTINCT applicable_manufacturer_or_applicable_gpo_making_payment_name) as num_manufacturers,
    SUM(total_amount_of_payment_us_dollars) as total_investment,
    AVG(total_amount_of_payment_us_dollars) as avg_investment_per_study
  FROM mimi_ws_1.openpayments.research
  WHERE product_category_or_therapeutic_area_1 IS NOT NULL
    AND total_amount_of_payment_us_dollars > 0
  GROUP BY 1,2
)

SELECT
  therapeutic_area,
  program_year,
  num_studies,
  num_manufacturers,
  ROUND(total_investment,2) as total_investment_usd,
  ROUND(avg_investment_per_study,2) as avg_investment_per_study_usd,
  -- Calculate percentage of total research investment
  ROUND(100.0 * total_investment / SUM(total_investment) OVER (PARTITION BY program_year),2) 
    as pct_of_year_total
FROM research_by_therapeutic_area
WHERE therapeutic_area != 'N/A'
ORDER BY program_year DESC, total_investment DESC;

/*
HOW IT WORKS:
1. Groups research payments by therapeutic area and program year
2. Calculates key metrics: study count, manufacturer count, total/avg investments
3. Computes each therapeutic area's share of total research spending per year
4. Filters out null and N/A values for clean analysis

ASSUMPTIONS & LIMITATIONS:
- Uses primary therapeutic area only (product_category_or_therapeutic_area_1)
- Assumes positive payment amounts represent actual investments
- Limited to studies with defined therapeutic areas
- May include some duplicate studies if reported differently

POSSIBLE EXTENSIONS:
1. Add trend analysis comparing year-over-year changes
2. Break down by specific manufacturers to show research focus areas
3. Cross-reference with clinical trial phases
4. Analyze seasonal patterns in research investments
5. Include geographic distribution of research by therapeutic area
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:40:29.095442
    - Additional Notes: Query focuses on first therapeutic area only per record and excludes records with missing/N/A categories. Payment amounts are assumed to be validated and inflation-adjusted. Results may need additional filtering if therapeutic area categorizations are inconsistent across years.
    
    */