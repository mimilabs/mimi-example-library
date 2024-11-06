-- Title: Table Coverage and Completeness Analysis
-- Purpose: Evaluate data completeness and coverage across schemas and tables
-- Business Value: Helps identify data gaps and quality issues to prioritize data quality improvements

/* 
This query analyzes table and column coverage patterns to:
1. Identify tables missing critical documentation
2. Highlight potential data quality gaps
3. Guide data governance priorities
4. Support data discovery efforts
*/

WITH base_metrics AS (
  SELECT 
    schema,
    table,
    COUNT(DISTINCT column) as column_count,
    COUNT(CASE WHEN comment IS NOT NULL AND comment != '' THEN 1 END) as documented_columns,
    COUNT(CASE WHEN example IS NOT NULL THEN 1 END) as columns_with_examples
  FROM mimi_ws_1.mimilabs.columnstats
  GROUP BY schema, table
),

coverage_analysis AS (
  SELECT
    schema,
    table,
    column_count,
    documented_columns,
    columns_with_examples,
    ROUND(100.0 * documented_columns / column_count, 1) as documentation_coverage_pct,
    ROUND(100.0 * columns_with_examples / column_count, 1) as example_coverage_pct
  FROM base_metrics
)

SELECT
  schema,
  table,
  column_count,
  documentation_coverage_pct,
  example_coverage_pct,
  CASE 
    WHEN documentation_coverage_pct >= 80 THEN 'High'
    WHEN documentation_coverage_pct >= 50 THEN 'Medium'
    ELSE 'Low'
  END as documentation_quality,
  CASE
    WHEN example_coverage_pct >= 80 THEN 'High'
    WHEN example_coverage_pct >= 50 THEN 'Medium' 
    ELSE 'Low'
  END as data_quality_indicator
FROM coverage_analysis
ORDER BY column_count DESC, documentation_coverage_pct DESC;

/*
How it works:
- First CTE calculates raw counts of columns, documented columns, and columns with examples
- Second CTE calculates coverage percentages
- Final query adds quality indicators based on coverage thresholds

Assumptions:
- Higher documentation coverage suggests better data governance
- Presence of examples indicates actively used/validated columns
- Column count can indicate table complexity

Limitations:
- Does not assess actual data quality, only metadata completeness
- Documentation quality assessment is based on presence, not content
- Example presence is a proxy for data quality

Possible Extensions:
1. Add trends over time using mimi_dlt_load_date
2. Include data type distribution analysis
3. Add specific business domain categorization
4. Create quality score weighting system
5. Compare coverage across different schemas
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:08:21.798536
    - Additional Notes: Query focuses on metadata quality metrics rather than direct table statistics. Coverage percentages and quality indicators provide actionable insights for data governance teams. Consider adjusting the threshold values (80% and 50%) based on organizational standards.
    
    */