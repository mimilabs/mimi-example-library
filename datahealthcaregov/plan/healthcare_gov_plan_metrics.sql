
/* 
Healthcare.gov Plan Analysis - Basic Overview
==========================================

Business Purpose:
This query provides a high-level analysis of health insurance plans available on Healthcare.gov,
focusing on plan distribution across years, networks, and marketing approaches. This insight
helps understand market offerings and trends in health insurance plans.

Author: AI Assistant
Created: 2024
*/

-- Main analysis of healthcare.gov plans
WITH yearly_stats AS (
  -- Get key metrics by year
  SELECT 
    years,
    COUNT(DISTINCT plan_id) as total_plans,
    COUNT(DISTINCT network) as network_types,
    COUNT(DISTINCT CASE WHEN marketing_url IS NOT NULL THEN plan_id END) as plans_with_marketing
  FROM mimi_ws_1.datahealthcaregov.plan
  GROUP BY years
),

network_breakdown AS (
  -- Analyze network distribution
  SELECT
    years,
    network,
    COUNT(*) as plan_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY years), 2) as network_percentage
  FROM mimi_ws_1.datahealthcaregov.plan
  WHERE network IS NOT NULL
  GROUP BY years, network
)

-- Combine the analyses
SELECT
  y.years,
  y.total_plans,
  y.network_types,
  y.plans_with_marketing,
  ROUND(y.plans_with_marketing * 100.0 / y.total_plans, 2) as pct_with_marketing,
  -- Simplified network reporting
  MAX(n.plan_count) as largest_network_size,
  MAX(n.network_percentage) as largest_network_pct
FROM yearly_stats y
LEFT JOIN network_breakdown n ON y.years = n.years
GROUP BY 
  y.years,
  y.total_plans,
  y.network_types,
  y.plans_with_marketing
ORDER BY y.years DESC;

/*
HOW IT WORKS:
1. yearly_stats CTE calculates key metrics per year
2. network_breakdown CTE analyzes network type distribution
3. Main query combines these views with percentage calculations
4. Results show plan counts, network diversity, and marketing coverage by year

ASSUMPTIONS & LIMITATIONS:
- Assumes plan_id is unique identifier
- Null networks are excluded from network distribution analysis
- Marketing presence based on marketing_url existence
- Years field contains valid data
- Shows size and percentage of largest network per year

POSSIBLE EXTENSIONS:
1. Add trend analysis comparing year-over-year changes
2. Include plan_id_type distribution analysis
3. Analyze correlation between network types and marketing presence
4. Add geographical analysis if location data available
5. Include summary_url availability analysis
6. Add seasonality analysis using last_updated_on dates
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:05:26.116445
    - Additional Notes: Query provides year-over-year comparison of healthcare.gov insurance plans, focusing on total plans, network types, and marketing metrics. Note that network analysis excludes null values and percentages are rounded to 2 decimal places. Results are ordered by most recent year first.
    
    */