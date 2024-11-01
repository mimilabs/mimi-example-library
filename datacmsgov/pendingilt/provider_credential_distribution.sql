-- First-Time Provider Credentials Pattern Analysis

-- Business Purpose:
-- Analyzes patterns in provider names to identify credentials distribution
-- and potential standardization needs in the enrollment process.
-- This helps:
-- 1. Improve data quality standards for provider names
-- 2. Support credential verification workflows
-- 3. Identify potential training needs for application processing staff

WITH credential_patterns AS (
  SELECT 
    -- Extract potential credentials from last name (e.g., MD, DO, NP)
    REGEXP_EXTRACT(last_name, '([A-Z]{2,})$') as credential,
    COUNT(*) as credential_count,
    -- Calculate percentage of total
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage
  FROM mimi_ws_1.datacmsgov.pendingilt
  WHERE last_name IS NOT NULL
  GROUP BY credential
  HAVING credential IS NOT NULL
),

name_length_metrics AS (
  SELECT 
    AVG(LENGTH(last_name)) as avg_last_name_length,
    AVG(LENGTH(first_name)) as avg_first_name_length,
    STDDEV(LENGTH(last_name)) as std_last_name_length,
    STDDEV(LENGTH(first_name)) as std_first_name_length
  FROM mimi_ws_1.datacmsgov.pendingilt
  WHERE last_name IS NOT NULL 
    AND first_name IS NOT NULL
)

SELECT 
  credential,
  credential_count,
  ROUND(percentage, 2) as percentage,
  m.avg_last_name_length,
  m.avg_first_name_length,
  m.std_last_name_length,
  m.std_first_name_length
FROM credential_patterns p
CROSS JOIN name_length_metrics m
WHERE credential_count > 5
ORDER BY credential_count DESC;

-- How this query works:
-- 1. Extracts potential credentials from last names using regex
-- 2. Calculates frequency and percentage for each credential
-- 3. Computes name length statistics for context
-- 4. Combines results to show credential patterns with name metrics

-- Assumptions and Limitations:
-- - Assumes credentials appear at end of last name in capital letters
-- - May capture some false positives (e.g., last names ending in caps)
-- - Limited to credentials of 2 or more letters
-- - Excludes credentials appearing fewer than 5 times
-- - Does not account for multiple credentials or complex formats

-- Possible Extensions:
-- 1. Add validation against known credential list
-- 2. Break out analysis by physician vs non-physician
-- 3. Track credential patterns over time using _input_file_date
-- 4. Analyze common name formatting inconsistencies
-- 5. Compare against historical approved applications

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:37:54.509034
    - Additional Notes: The query may need tuning for performance with large datasets due to multiple full table scans. Consider adding filters on _input_file_date if analyzing specific time periods. The regex pattern for credential extraction may need adjustment based on actual credential formatting standards in the data.
    
    */