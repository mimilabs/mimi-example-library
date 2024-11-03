-- Title: New York Medicaid Provider Email Communication Coverage Analysis

-- Business Purpose: 
-- Analyze provider email availability to assess digital communication readiness
-- and identify gaps in provider contact information. This helps support:
-- 1. Digital transformation initiatives for provider communications
-- 2. Provider engagement campaign planning
-- 3. Areas needing improved provider contact data collection

WITH provider_email_status AS (
  -- Categorize providers based on email availability
  SELECT 
    county,
    medicaid_type,
    profession_or_service,
    CASE 
      WHEN provider_email IS NOT NULL AND TRIM(provider_email) != '' THEN 'Has Email'
      ELSE 'Missing Email'
    END as email_status,
    COUNT(*) as provider_count
  FROM mimi_ws_1.stategov.newyork_medicaid_provider_directory
  -- Get latest snapshot only
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.stategov.newyork_medicaid_provider_directory)
  GROUP BY 1,2,3,4
)

SELECT
  county,
  medicaid_type,
  profession_or_service,
  SUM(CASE WHEN email_status = 'Has Email' THEN provider_count ELSE 0 END) as providers_with_email,
  SUM(CASE WHEN email_status = 'Missing Email' THEN provider_count ELSE 0 END) as providers_without_email,
  SUM(provider_count) as total_providers,
  ROUND(100.0 * SUM(CASE WHEN email_status = 'Has Email' THEN provider_count ELSE 0 END) / 
    SUM(provider_count), 1) as email_coverage_pct
FROM provider_email_status
GROUP BY 1,2,3
HAVING total_providers >= 10  -- Focus on groups with meaningful sample sizes
ORDER BY total_providers DESC, email_coverage_pct
LIMIT 100;

-- How it works:
-- 1. Creates a CTE to categorize providers based on email availability
-- 2. Gets the latest snapshot using mimi_src_file_date
-- 3. Aggregates providers by county, type, and profession
-- 4. Calculates email coverage metrics
-- 5. Filters for provider groups with at least 10 members
-- 6. Orders by total providers and coverage percentage

-- Assumptions and Limitations:
-- 1. Email addresses are stored in standard format
-- 2. Blank/null emails are treated as missing
-- 3. Latest snapshot represents current state
-- 4. Groups with <10 providers excluded to avoid skewed percentages

-- Possible Extensions:
-- 1. Add trend analysis across multiple snapshots
-- 2. Include provider specialty analysis
-- 3. Add validation of email format correctness
-- 4. Compare email coverage by provider size/volume
-- 5. Analyze correlation with other provider characteristics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:48:12.243131
    - Additional Notes: Query focuses on identifying digital communication gaps by analyzing email availability patterns across provider categories. Only includes provider groups with 10+ members for statistical significance. The analysis is snapshot-based and does not reflect historical trends.
    
    */