-- Title: NHANES Financial Transportation Access Analysis

-- Business Purpose: 
-- Analyze how transportation access to grocery stores relates to family income levels
-- and savings behavior. This provides insights into potential barriers to food access
-- and financial wellness, which can inform public health and community development initiatives.

-- Main Query
WITH transportation_summary AS (
  -- Analyze grocery store transportation methods by income level
  SELECT 
    indfmmpc AS poverty_level_category,
    inq320 AS transportation_method,
    COUNT(*) AS household_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY indfmmpc), 1) AS pct_within_income_level
  FROM mimi_ws_1.cdc.nhanes_qre_income
  WHERE inq320 IS NOT NULL 
    AND indfmmpc IS NOT NULL
  GROUP BY indfmmpc, inq320
),

savings_by_transport AS (
  -- Look at savings patterns within transportation methods
  SELECT 
    inq320 AS transportation_method,
    CASE 
      WHEN inq300 = 1 THEN 'Over $20k'
      WHEN inq244 = 1 THEN 'Over $5k'
      ELSE 'Under $5k'
    END AS savings_level,
    COUNT(*) AS household_count
  FROM mimi_ws_1.cdc.nhanes_qre_income
  WHERE inq320 IS NOT NULL
    AND (inq300 IS NOT NULL OR inq244 IS NOT NULL)
  GROUP BY inq320, 
    CASE 
      WHEN inq300 = 1 THEN 'Over $20k'
      WHEN inq244 = 1 THEN 'Over $5k'
      ELSE 'Under $5k'
    END
)

SELECT 
  t.poverty_level_category,
  t.transportation_method,
  t.household_count,
  t.pct_within_income_level AS pct_using_transport,
  s.savings_level,
  s.household_count AS households_with_savings
FROM transportation_summary t
LEFT JOIN savings_by_transport s
  ON t.transportation_method = s.transportation_method
ORDER BY 
  t.poverty_level_category,
  t.pct_within_income_level DESC,
  s.savings_level;

-- How it works:
-- 1. First CTE summarizes transportation methods used by poverty level category
-- 2. Second CTE analyzes savings levels within each transportation method
-- 3. Main query joins these views to show relationships between income, transportation, and savings
-- 4. Results are ordered to highlight most common transportation methods within each income level

-- Assumptions and Limitations:
-- - Assumes transportation method (inq320) responses are current and representative
-- - Limited to respondents with non-null transportation and income data
-- - Savings data may be incomplete as questions varied across survey years
-- - Transportation options may not capture all possible methods

-- Possible Extensions:
-- 1. Add geographic analysis if location data is available
-- 2. Include distance to grocery stores if available in related tables
-- 3. Analyze seasonal variations in transportation methods
-- 4. Correlate with health outcomes from other NHANES tables
-- 5. Compare transportation patterns across different demographic groups

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:54:48.130039
    - Additional Notes: Query assumes consistent transportation method coding across survey years. Results should be interpreted with caution for areas with limited public transportation options or significant seasonal weather variations that may affect transportation choices.
    
    */