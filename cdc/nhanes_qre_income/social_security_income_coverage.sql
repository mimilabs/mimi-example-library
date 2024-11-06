-- Title: NHANES Social Security Income Impact Analysis

-- Business Purpose:
-- Analyze the relationship between Social Security income receipt and other retirement/disability
-- income sources to understand income security patterns among beneficiaries.
-- This helps identify potential gaps in retirement and disability coverage
-- and informs policy discussions around social safety net programs.

WITH social_security_recipients AS (
  -- Identify recipients of Social Security/Railroad Retirement
  SELECT 
    seqn,
    indfmmpi,
    indfmmpc,
    inq030 as receives_social_security,
    inq060 as receives_disability,
    inq080 as receives_other_pension,
    ind235 as monthly_income_range
  FROM mimi_ws_1.cdc.nhanes_qre_income
  WHERE inq030 = 1  -- Social Security recipients
),

summary_stats AS (
  -- Calculate key metrics for Social Security recipients
  SELECT
    COUNT(*) as total_recipients,
    AVG(indfmmpi) as avg_poverty_index,
    COUNT(CASE WHEN receives_disability = 1 THEN 1 END) as disability_count,
    COUNT(CASE WHEN receives_other_pension = 1 THEN 1 END) as other_pension_count,
    COUNT(CASE WHEN monthly_income_range <= 3 THEN 1 END) as low_income_count
  FROM social_security_recipients
)

SELECT 
  total_recipients,
  ROUND(avg_poverty_index, 2) as avg_poverty_index,
  ROUND(disability_count * 100.0 / total_recipients, 1) as pct_with_disability,
  ROUND(other_pension_count * 100.0 / total_recipients, 1) as pct_with_other_pension,
  ROUND(low_income_count * 100.0 / total_recipients, 1) as pct_low_income
FROM summary_stats;

-- How the Query Works:
-- 1. First CTE identifies Social Security/Railroad Retirement recipients
-- 2. Second CTE calculates summary statistics for this population
-- 3. Final query formats results as percentages for easy interpretation

-- Assumptions and Limitations:
-- - Assumes inq030=1 indicates actual receipt of benefits (vs. pending/denied)
-- - Low income defined as monthly_income_range <= 3 (adjust as needed)
-- - Does not account for benefit amount variations
-- - Cross-sectional analysis only (no longitudinal trends)

-- Possible Extensions:
-- 1. Add demographic breakdowns (age groups, gender, etc.)
-- 2. Compare metrics against non-Social Security recipients
-- 3. Analyze geographic variations if location data available
-- 4. Include supplemental security income (SSI) analysis
-- 5. Examine intersection with other assistance programs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:49:47.128223
    - Additional Notes: Query focuses on core Social Security recipient metrics but current structure may need index optimization for large datasets. Consider adding WHERE clause filters on mimi_src_file_date if analyzing specific time periods. Monthly income ranges (ind235) should be validated against current poverty thresholds before production use.
    
    */