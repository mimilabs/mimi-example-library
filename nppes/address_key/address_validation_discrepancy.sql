-- Address Duplication and Validation Analysis
-- Business Purpose: Identify potential data quality issues and validate address consistency
-- by comparing business and mailing address counts to find mismatches that may indicate:
-- - Data entry errors
-- - Address standardization problems
-- - Potential provider location discrepancies
-- This helps maintain data quality and improves provider location accuracy

WITH address_metrics AS (
    SELECT 
        address_key,
        -- Calculate total address usage across all types
        (npi_b1_cnt + npi_b2_cnt + npi_m1_cnt) as total_usage,
        -- Compare business vs mailing address counts
        ABS(npi_b1_cnt - npi_m1_cnt) as address_type_diff,
        -- Calculate percentage difference between address types
        CASE 
            WHEN npi_m1_cnt > 0 
            THEN (ABS(npi_b1_cnt - npi_m1_cnt)::FLOAT / npi_m1_cnt) * 100
            ELSE 0 
        END as diff_percentage
    FROM mimi_ws_1.nppes.address_key
    WHERE mimi_dlt_load_date = (SELECT MAX(mimi_dlt_load_date) FROM mimi_ws_1.nppes.address_key)
)

SELECT 
    address_key,
    total_usage,
    address_type_diff,
    ROUND(diff_percentage, 2) as diff_percentage
FROM address_metrics
WHERE diff_percentage >= 50  -- Focus on significant discrepancies
  AND total_usage >= 10     -- Filter for frequently used addresses
ORDER BY diff_percentage DESC, total_usage DESC
LIMIT 100;

-- How it works:
-- 1. Creates metrics for each unique address comparing business and mailing usage
-- 2. Calculates absolute and percentage differences between address types
-- 3. Filters for addresses with significant discrepancies (>50%) and meaningful sample size
-- 4. Returns top 100 cases sorted by discrepancy magnitude

-- Assumptions and Limitations:
-- - Assumes current data (uses latest mimi_dlt_load_date)
-- - Focuses on active addresses (minimum usage threshold)
-- - Does not account for legitimate reasons for business/mailing address differences
-- - Limited to top 100 cases for initial analysis

-- Possible Extensions:
-- 1. Add geographic analysis by parsing state from address_key
-- 2. Implement threshold parameters for easier tuning
-- 3. Add temporal analysis comparing patterns across load dates
-- 4. Include additional validation rules based on address format
-- 5. Create summary statistics by address components
-- 6. Develop address standardization recommendations based on patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:20:44.393798
    - Additional Notes: Query identifies addresses with significant disparities between business and mailing usage counts, focusing on frequently used addresses (10+ occurrences) with >50% difference in usage patterns. Best used for data quality monitoring and address standardization initiatives.
    
    */