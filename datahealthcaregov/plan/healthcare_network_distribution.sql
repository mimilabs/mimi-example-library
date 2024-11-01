-- Healthcare.gov Plan Network Analysis
-- ==========================================
-- Business Purpose: Analyze plan network types and their prevalence across years
-- to understand market trends in provider network configurations and assess
-- network adequacy implications for healthcare access.

-- Main Query
WITH network_trends AS (
  SELECT 
    years,
    network,
    COUNT(*) as plan_count,
    -- Calculate percentage of each network type within year
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY years), 2) as network_pct
  FROM mimi_ws_1.datahealthcaregov.plan
  WHERE network IS NOT NULL 
    AND years IS NOT NULL
  GROUP BY years, network
)

SELECT 
  years,
  network,
  plan_count,
  network_pct,
  -- Create visual representation of percentage
  REPEAT('■', CAST(network_pct/5 AS INT)) as distribution
FROM network_trends
ORDER BY years DESC, plan_count DESC;

-- How this query works:
-- 1. First CTE aggregates plans by year and network type
-- 2. Calculates both raw counts and percentages within each year
-- 3. Main query adds visual distribution for easy pattern recognition
-- 4. Results ordered by most recent years and highest plan counts

-- Assumptions and Limitations:
-- - Assumes network field is standardized and meaningful
-- - Limited to plans with non-null network and year values
-- - Percentages rounded to 2 decimal places
-- - Distribution visualization scale set to 1 block = 5%

-- Possible Extensions:
-- 1. Add year-over-year change in network type prevalence
-- 2. Cross-reference with marketing names to identify naming patterns
-- 3. Include geographic analysis by parsing plan_id regional components
-- 4. Compare network distributions against industry benchmarks
-- 5. Analyze correlation between network types and marketing approaches

-- Business Value:
-- - Identifies dominant network models in marketplace plans
-- - Tracks evolution of network strategies over time
-- - Supports network adequacy assessment and access planning
-- - Informs competitive analysis and market positioning
-- - Helps understand consumer choice patterns in plan selection

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:36:06.079427
    - Additional Notes: Query focuses on temporal network type distribution analysis. Note that visualization component using REPEAT() function may need adjustment based on actual percentage ranges in the data. Consider adding filters for specific years if the dataset spans a very long time period.
    
    */