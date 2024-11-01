/*
FDA Orange Book Generic Drug Competition Analysis
Business Purpose:
- Identify therapeutic areas with high/low generic competition
- Support market entry strategy for generic drug manufacturers
- Highlight opportunities for increased generic drug development
- Monitor generic drug availability trends across drug categories
*/

WITH generic_counts AS (
  -- Count number of generic versions per unique drug (ingredient + form + strength)
  SELECT 
    ingredient,
    df_route,
    strength,
    COUNT(CASE WHEN appl_type = 'ANDA' THEN 1 END) as generic_count,
    COUNT(CASE WHEN appl_type = 'NDA' THEN 1 END) as brand_count
  FROM mimi_ws_1.fda.orangebook_products
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.fda.orangebook_products)
  GROUP BY ingredient, df_route, strength
),

competition_metrics AS (
  -- Calculate competition metrics and categorize products
  SELECT
    ingredient,
    df_route,
    strength,
    generic_count,
    brand_count,
    CASE 
      WHEN generic_count = 0 THEN 'No Generic Competition'
      WHEN generic_count < 3 THEN 'Low Generic Competition'
      WHEN generic_count < 6 THEN 'Moderate Generic Competition'
      ELSE 'High Generic Competition'
    END as competition_level
  FROM generic_counts
)

-- Final output with market opportunity analysis
SELECT
  competition_level,
  COUNT(*) as product_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percent_of_total,
  AVG(generic_count) as avg_generic_count,
  AVG(brand_count) as avg_brand_count
FROM competition_metrics
GROUP BY competition_level
ORDER BY product_count DESC;

/*
How this query works:
1. First CTE counts generic and brand versions for each unique drug combination
2. Second CTE categorizes products by competition level
3. Final query summarizes market opportunity metrics

Assumptions and Limitations:
- Uses latest data snapshot only
- Assumes ANDA = generic and NDA = brand
- Doesn't account for product discontinuations
- Competition levels are arbitrarily defined thresholds

Possible Extensions:
1. Add therapeutic category analysis
2. Track competition trends over time
3. Include market size/revenue potential
4. Add patent expiration analysis
5. Segment by route of administration
6. Include recent approval dates
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:36:52.143607
    - Additional Notes: Query focuses on competition intensity analysis in the generic drug market. Key metrics include competition levels (none/low/moderate/high) and average number of generic competitors per drug. Best used for market opportunity assessment and strategic planning for generic drug manufacturers.
    
    */