
/* FDA Purple Book Analysis - Top Manufacturers and Recent Approvals
 *
 * Business Purpose:
 * This query provides key insights into FDA-licensed biological products by:
 * 1. Identifying the top manufacturers by number of approved products
 * 2. Showing recent approval trends
 * 3. Highlighting distribution across different administration routes
 * This helps stakeholders understand market concentration and emerging trends.
 */

WITH top_manufacturers AS (
  -- Get top 10 manufacturers by number of approved products
  SELECT 
    applicant,
    COUNT(DISTINCT bla_number) as product_count
  FROM mimi_ws_1.fda.purplebook
  WHERE marketing_status = 'Active' -- Focus on currently active products
  GROUP BY applicant
  ORDER BY product_count DESC
  LIMIT 10
),

recent_approvals AS (
  -- Get approval trends for last 5 years
  SELECT 
    YEAR(approval_date) as approval_year,
    COUNT(*) as new_approvals
  FROM mimi_ws_1.fda.purplebook
  WHERE approval_date >= add_months(current_date(), -60) -- Last 5 years
  GROUP BY YEAR(approval_date)
  ORDER BY approval_year
)

-- Combine insights into final result set
SELECT
  'Top Manufacturers' as insight_type,
  m.applicant as metric_name,
  CAST(m.product_count as STRING) as metric_value
FROM top_manufacturers m

UNION ALL

SELECT 
  'Annual Approvals',
  CAST(r.approval_year as STRING),
  CAST(r.new_approvals as STRING)
FROM recent_approvals r

UNION ALL

-- Add route of administration distribution
SELECT
  'Administration Routes',
  route_of_administration,
  CAST(COUNT(*) as STRING) as count
FROM mimi_ws_1.fda.purplebook
WHERE route_of_administration IS NOT NULL
GROUP BY route_of_administration
ORDER BY insight_type, metric_value DESC;

/* How it works:
 * 1. First CTE gets top manufacturers by counting distinct BLA numbers
 * 2. Second CTE analyzes approval trends over last 5 years using add_months()
 * 3. Main query combines these insights with administration route distribution
 * 4. Results are formatted consistently with string casting
 *
 * Assumptions & Limitations:
 * - Assumes 'Active' status is current and accurate
 * - Limited to top 10 manufacturers
 * - 5-year window for trends may miss longer-term patterns
 * - Null values in route_of_administration are excluded
 *
 * Possible Extensions:
 * 1. Add dosage form distribution analysis
 * 2. Include exclusivity expiration forecasting
 * 3. Compare biosimilar vs original product trends
 * 4. Add therapeutic area categorization
 * 5. Incorporate market share analysis using additional data sources
 */
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:51:57.327022
    - Additional Notes: Query provides a comprehensive market overview through three key metrics: manufacturer concentration, approval trends, and administration routes. The 5-year lookback period is hard-coded using add_months(-60), which may need adjustment for different time horizons. Results are standardized as string values for consistent display formatting.
    
    */