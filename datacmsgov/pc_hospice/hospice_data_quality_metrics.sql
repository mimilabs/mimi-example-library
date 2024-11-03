-- Medicare Hospice Provider Data Completeness Analysis - Monitoring Reporting Quality
-- 
-- Business Purpose: Assess and monitor the completeness and accuracy of critical 
-- Medicare hospice enrollment data fields to:
-- - Ensure regulatory compliance and data quality
-- - Identify providers with missing required information
-- - Support data governance initiatives
-- - Track reporting trends over time

WITH field_stats AS (
  SELECT 
    mimi_src_file_date,
    COUNT(*) as total_providers,
    -- Calculate missing counts
    SUM(CASE WHEN npi IS NULL THEN 1 ELSE 0 END) as count_missing_npi,
    SUM(CASE WHEN ccn IS NULL THEN 1 ELSE 0 END) as count_missing_ccn,
    SUM(CASE WHEN organization_name IS NULL THEN 1 ELSE 0 END) as count_missing_org_name,
    SUM(CASE WHEN incorporation_date IS NULL THEN 1 ELSE 0 END) as count_missing_inc_date,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) as count_missing_state
  FROM mimi_ws_1.datacmsgov.pc_hospice
  GROUP BY mimi_src_file_date
)

SELECT 
  mimi_src_file_date,
  total_providers,
  -- Calculate completeness percentages
  ROUND(100.0 * count_missing_npi / total_providers, 2) as pct_missing_npi,
  ROUND(100.0 * count_missing_ccn / total_providers, 2) as pct_missing_ccn,
  ROUND(100.0 * count_missing_org_name / total_providers, 2) as pct_missing_org_name,
  ROUND(100.0 * count_missing_inc_date / total_providers, 2) as pct_missing_inc_date,
  ROUND(100.0 * count_missing_state / total_providers, 2) as pct_missing_state,
  -- Calculate overall data quality score
  ROUND(100.0 * (1 - (CAST(count_missing_npi + count_missing_ccn + count_missing_org_name + 
    count_missing_inc_date + count_missing_state AS FLOAT) / (total_providers * 5))), 2) 
    as overall_quality_score
FROM field_stats
ORDER BY mimi_src_file_date DESC;

-- How the query works:
-- 1. Creates a CTE that calculates counts of missing values for critical enrollment fields
-- 2. Aggregates the results by file date to track completeness over time
-- 3. Calculates percentages of missing data for each field
-- 4. Generates an overall quality score based on field completeness

-- Assumptions and limitations:
-- - All fields are weighted equally in the quality score
-- - Null values are considered missing data
-- - Does not assess data accuracy, only completeness
-- - Limited to key identifying and regulatory fields

-- Possible extensions:
-- 1. Add validation rules for field formats (e.g., NPI length, valid state codes)
-- 2. Include trend analysis across multiple reporting periods
-- 3. Break down completeness by state or organization type
-- 4. Add alerts for providers missing multiple critical fields
-- 5. Compare completeness rates between for-profit and non-profit providers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:05:57.483738
    - Additional Notes: The query provides a time-series view of data quality metrics across critical Medicare hospice enrollment fields. It calculates both individual field completion rates and an aggregate quality score. Note that the quality score treats all fields as equally important, which may not reflect true business priorities. Consider adjusting the weighting in the overall_quality_score calculation based on specific regulatory or operational requirements.
    
    */