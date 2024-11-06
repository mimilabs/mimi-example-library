-- deletion_patterns_by_payment_type.sql

-- Business Purpose: 
-- Analyze deletion patterns across payment types to identify potential compliance risks
-- and data quality issues that could impact healthcare transparency reporting.
-- This insight helps organizations improve their data submission processes and
-- compliance programs.

-- Main Query
WITH payment_type_metrics AS (
  SELECT 
    payment_type,
    COUNT(*) as total_deletions,
    COUNT(DISTINCT program_year) as years_affected,
    MIN(program_year) as earliest_year,
    MAX(program_year) as latest_year
  FROM mimi_ws_1.openpayments.deleted
  GROUP BY payment_type
),
ranked_deletions AS (
  SELECT 
    payment_type,
    total_deletions,
    years_affected,
    -- Calculate percentage of total deletions
    ROUND(100.0 * total_deletions / SUM(total_deletions) OVER(), 2) as pct_of_total,
    -- Calculate average deletions per year
    ROUND(1.0 * total_deletions / years_affected, 2) as avg_deletions_per_year,
    earliest_year,
    latest_year
  FROM payment_type_metrics
)
SELECT *
FROM ranked_deletions
ORDER BY total_deletions DESC;

-- Query Operation:
-- 1. Aggregates deletion counts and year spans by payment type
-- 2. Calculates percentage distribution and yearly averages
-- 3. Provides a comprehensive view of deletion patterns that can guide compliance efforts

-- Assumptions and Limitations:
-- - Assumes all payment types are consistently categorized
-- - Does not account for seasonal variations in deletions
-- - Cannot determine the root cause of deletions
-- - Historical data completeness may vary by year

-- Possible Extensions:
-- 1. Add trend analysis by comparing year-over-year changes
-- 2. Include change_type breakdown for each payment type
-- 3. Calculate deletion rates relative to total submissions
-- 4. Add seasonality analysis by incorporating load dates
-- 5. Compare deletion patterns across different reporting periods

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:14:36.675608
    - Additional Notes: Query provides high-level metrics on deletion patterns by payment type but requires sufficient historical data across multiple program years for meaningful averages. Consider using WITH ROLLUP or window functions for more granular analysis if needed for specific compliance reporting periods.
    
    */