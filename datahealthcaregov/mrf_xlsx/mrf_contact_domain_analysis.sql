-- Healthcare.gov MRF Technical Contact Domain Analysis
-- ===============================================

-- Business Purpose:
-- This query analyzes the email domains used by technical points of contact (POCs)
-- across healthcare issuers to:
-- 1. Identify if issuers are using enterprise vs personal email domains
-- 2. Detect potential data quality issues in contact information
-- 3. Help establish communication patterns and vendor relationships
-- 4. Support outreach strategy planning

WITH domain_extract AS (
    -- Extract domain from email and standardize
    SELECT 
        LOWER(REGEXP_EXTRACT(tech_poc_email, '@(.+)$')) as email_domain,
        state,
        issuer_id,
        tech_poc_email,
        mimi_src_file_date
    FROM mimi_ws_1.datahealthcaregov.mrf_xlsx
    WHERE tech_poc_email IS NOT NULL
),

domain_summary AS (
    -- Summarize domain usage patterns
    SELECT 
        email_domain,
        COUNT(DISTINCT issuer_id) as issuer_count,
        COUNT(DISTINCT state) as state_count,
        CONCAT_WS(', ', COLLECT_SET(state)) as states_list,
        MIN(mimi_src_file_date) as first_seen_date,
        MAX(mimi_src_file_date) as last_seen_date
    FROM domain_extract
    GROUP BY email_domain
)

-- Final output with key metrics
SELECT 
    email_domain,
    issuer_count,
    state_count,
    states_list,
    first_seen_date,
    last_seen_date,
    -- Calculate domain type indicators
    CASE 
        WHEN email_domain LIKE '%.gov' THEN 'Government'
        WHEN email_domain LIKE '%.edu' THEN 'Educational'
        WHEN email_domain IN ('gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com') THEN 'Personal'
        ELSE 'Enterprise'
    END as domain_type
FROM domain_summary
WHERE issuer_count > 1  -- Focus on domains used by multiple issuers
ORDER BY issuer_count DESC, state_count DESC;

-- How this works:
-- 1. First CTE extracts and standardizes email domains from POC emails
-- 2. Second CTE aggregates domain usage statistics using COLLECT_SET for state list
-- 3. Final query adds domain type classification and filters for relevant results

-- Assumptions and Limitations:
-- 1. Assumes email addresses are properly formatted
-- 2. Domain type classification is based on simple pattern matching
-- 3. Personal email classification limited to major providers
-- 4. Results depend on data completeness in tech_poc_email field

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in contact patterns over time
-- 2. Cross-reference with MRF submission quality metrics
-- 3. Expand domain classification with more detailed vendor categorization
-- 4. Add geographical clustering analysis
-- 5. Include validation checks for email format and domain existence

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:34:40.289078
    - Additional Notes: Query focuses on email domain patterns across healthcare issuers and may need performance optimization for large datasets. The COLLECT_SET function used for state aggregation might have memory implications with very large state lists. Consider monitoring execution time and memory usage when running against full production data.
    
    */