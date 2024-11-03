-- Title: Immunization Vendor and Cost Analysis
-- Business Purpose: 
-- This analysis helps healthcare organizations optimize their immunization programs by:
-- 1. Identifying top immunization types by volume and cost
-- 2. Tracking spending patterns across different vaccine categories
-- 3. Supporting vendor contract negotiations and budget planning

WITH immunization_summary AS (
  -- Get core metrics by immunization type
  SELECT 
    description,
    code,
    COUNT(*) as total_administered,
    COUNT(DISTINCT patient) as unique_patients,
    ROUND(AVG(base_cost), 2) as avg_cost,
    ROUND(SUM(base_cost), 2) as total_cost,
    MIN(date) as first_administered,
    MAX(date) as last_administered
  FROM mimi_ws_1.synthea.immunizations
  GROUP BY description, code
),

rankings AS (
  -- Add volume and cost rankings
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_administered DESC) as volume_rank,
    ROW_NUMBER() OVER (ORDER BY total_cost DESC) as cost_rank
  FROM immunization_summary
)

SELECT
  description,
  code,
  total_administered,
  unique_patients,
  avg_cost,
  total_cost,
  volume_rank,
  cost_rank,
  first_administered,
  last_administered,
  -- Calculate contribution metrics
  ROUND(100.0 * total_cost / SUM(total_cost) OVER (), 2) as pct_of_total_cost,
  ROUND(100.0 * total_administered / SUM(total_administered) OVER (), 2) as pct_of_total_volume
FROM rankings
ORDER BY total_cost DESC;

-- How this query works:
-- 1. First CTE aggregates key metrics by immunization type
-- 2. Second CTE adds rankings based on volume and cost
-- 3. Final SELECT adds percentage contributions and orders by total cost

-- Assumptions & Limitations:
-- - Base costs are assumed to be consistent and accurate
-- - Analysis is at the immunization type level only
-- - Time trends are limited to first/last administration dates
-- - Does not account for any discounts or actual reimbursement amounts

-- Possible Extensions:
-- 1. Add year-over-year cost trend analysis
-- 2. Include patient demographic breakdowns
-- 3. Compare costs across different facilities or regions
-- 4. Add seasonal variation analysis
-- 5. Include inventory management metrics based on usage patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:59:57.442159
    - Additional Notes: This query focuses on financial and volume metrics that can directly support procurement decisions and budget planning. The results are particularly valuable for annual contract negotiations with vaccine suppliers and for identifying high-impact immunization types that drive significant costs or volume.
    
    */