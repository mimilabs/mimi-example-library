-- NNDSS Year-Over-Year Disease Impact Analysis
--
-- Business Purpose: 
-- Analyzes the year-over-year changes in disease burden to identify conditions showing
-- significant increases or decreases. This enables public health officials to:
-- 1. Detect emerging disease threats
-- 2. Evaluate effectiveness of intervention programs
-- 3. Allocate resources based on changing disease patterns
--
-- The analysis focuses on comparing current year vs previous year totals and calculating
-- the percentage change to highlight areas needing attention.

WITH current_totals AS (
  -- Get total cases by disease for current year
  SELECT 
    label,
    SUM(cumulative_ytd_current_mmwr_year) as current_year_total,
    current_mmwr_year
  FROM mimi_ws_1.cdc.nndss
  WHERE current_mmwr_year = (SELECT MAX(current_mmwr_year) FROM mimi_ws_1.cdc.nndss)
  GROUP BY label, current_mmwr_year
),

previous_totals AS (
  -- Get total cases by disease for previous year
  SELECT 
    label,
    SUM(cumulative_ytd_previous_mmwr_year) as previous_year_total
  FROM mimi_ws_1.cdc.nndss 
  WHERE current_mmwr_year = (SELECT MAX(current_mmwr_year) FROM mimi_ws_1.cdc.nndss)
  GROUP BY label
)

-- Calculate year-over-year changes and percentages
SELECT
  c.label as disease_condition,
  c.current_year_total,
  p.previous_year_total,
  (c.current_year_total - p.previous_year_total) as absolute_change,
  ROUND(
    CASE 
      WHEN p.previous_year_total = 0 THEN NULL
      ELSE ((c.current_year_total - p.previous_year_total) * 100.0 / p.previous_year_total)
    END, 
    1
  ) as percent_change,
  c.current_mmwr_year as year
FROM current_totals c
JOIN previous_totals p ON c.label = p.label
WHERE 
  -- Filter out rows where both years have zero cases
  NOT (c.current_year_total = 0 AND p.previous_year_total = 0)
ORDER BY ABS(
  CASE 
    WHEN p.previous_year_total = 0 THEN NULL
    ELSE ((c.current_year_total - p.previous_year_total) * 100.0 / p.previous_year_total)
  END
) DESC;

-- How it works:
-- 1. Creates CTEs to separately calculate current and previous year totals
-- 2. Joins the results and calculates absolute and percentage changes
-- 3. Orders results by absolute percentage change to highlight biggest shifts
-- 4. Handles edge cases like division by zero
--
-- Assumptions and limitations:
-- 1. Assumes data completeness for year-over-year comparisons
-- 2. Does not account for changes in reporting practices between years
-- 3. Percentage changes may be misleading for very small baseline numbers
--
-- Possible extensions:
-- 1. Add statistical significance testing for changes
-- 2. Include multi-year trends beyond just year-over-year
-- 3. Break down changes by geographic region
-- 4. Add seasonally adjusted comparisons
-- 5. Include confidence intervals for percentage changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:06:13.052319
    - Additional Notes: Query provides high-level disease impact trends but may need adjustment for specific reporting periods or jurisdictions with incomplete data. Consider adding data quality filters based on flag columns for more accurate comparisons.
    
    */