-- Title: Supply Cost Outlier Detection for Strategic Purchasing
-- 
-- Business Purpose:
-- This query identifies unusual patterns in medical supply usage that may indicate:
-- - Opportunities for bulk purchasing discounts
-- - Potential waste or inefficient supply utilization
-- - Supply usage variations that require investigation
-- - Areas for standardization of supply choices
--

WITH supply_metrics AS (
  -- Calculate baseline metrics for each supply code
  SELECT 
    code,
    description,
    COUNT(DISTINCT encounter) as total_encounters,
    SUM(quantity) as total_quantity,
    AVG(quantity) as avg_quantity_per_use,
    STDDEV(quantity) as std_dev_quantity
  FROM mimi_ws_1.synthea.supplies
  GROUP BY code, description
),

supply_rankings AS (
  -- Identify supplies with unusual usage patterns
  SELECT
    code,
    description,
    total_encounters,
    total_quantity,
    avg_quantity_per_use,
    std_dev_quantity,
    -- Flag high-volume items
    CASE 
      WHEN total_quantity > (SELECT PERCENTILE(total_quantity, 0.75) FROM supply_metrics)
      THEN 'High Volume'
      ELSE 'Normal Volume'
    END as volume_category,
    -- Flag items with high variability
    CASE
      WHEN std_dev_quantity > avg_quantity_per_use
      THEN 'High Variability'
      ELSE 'Normal Variability'
    END as variability_category
  FROM supply_metrics
)

-- Final output focusing on strategic opportunities
SELECT 
  code,
  description,
  total_encounters,
  total_quantity,
  ROUND(avg_quantity_per_use, 2) as avg_quantity_per_use,
  ROUND(std_dev_quantity, 2) as std_dev_quantity,
  volume_category,
  variability_category
FROM supply_rankings
WHERE volume_category = 'High Volume' 
   OR variability_category = 'High Variability'
ORDER BY total_quantity DESC, std_dev_quantity DESC;

-- How it works:
-- 1. First CTE establishes baseline usage metrics for each supply
-- 2. Second CTE adds categorical flags for volume and variability
-- 3. Final query filters for items of strategic interest
--
-- Assumptions and Limitations:
-- - Assumes quantity values are comparable across different supply types
-- - Does not account for supply costs (not available in current schema)
-- - Uses simplified statistical thresholds that may need adjustment
-- - Does not consider seasonality or trends over time
--
-- Possible Extensions:
-- 1. Add temporal analysis to identify seasonal patterns
-- 2. Include encounter type analysis for context
-- 3. Create supply categories for more nuanced comparisons
-- 4. Add year-over-year growth analysis
-- 5. Include correlation analysis with patient outcomes
-- 6. Add supply standardization recommendations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:30:07.268926
    - Additional Notes: Query focuses on statistical outliers in supply usage patterns, making it particularly valuable for purchasing departments and inventory managers. The 75th percentile threshold for high volume classification may need adjustment based on specific facility needs. Consider adding actual cost data if available for more actionable insights.
    
    */