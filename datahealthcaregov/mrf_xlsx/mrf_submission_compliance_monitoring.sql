-- MRF File Submission Compliance Analysis
-- ===============================================

-- Business Purpose:
-- This query analyzes the timeliness and completeness of MRF submissions by healthcare issuers
-- to identify potential compliance issues and data quality concerns. It helps identify issuers
-- that may need follow-up regarding their file submissions or technical contact information.

-- Main Query
WITH latest_submissions AS (
    -- Get the most recent submission date per issuer
    SELECT 
        issuer_id,
        state,
        MAX(mimi_src_file_date) as last_submission_date
    FROM mimi_ws_1.datahealthcaregov.mrf_xlsx
    GROUP BY issuer_id, state
),

submission_metrics AS (
    -- Calculate days since last submission and validate contact info
    SELECT 
        ls.issuer_id,
        ls.state,
        ls.last_submission_date,
        DATEDIFF(CURRENT_DATE(), ls.last_submission_date) as days_since_last_submission,
        COUNT(DISTINCT m.url_submitted) as total_urls_submitted,
        COUNT(DISTINCT CASE 
            WHEN m.tech_poc_email LIKE '%@%.%' 
            THEN m.tech_poc_email 
        END) as valid_email_contacts
    FROM latest_submissions ls
    JOIN mimi_ws_1.datahealthcaregov.mrf_xlsx m
        ON ls.issuer_id = m.issuer_id 
        AND ls.state = m.state
    GROUP BY ls.issuer_id, ls.state, ls.last_submission_date
)

SELECT 
    state,
    COUNT(DISTINCT issuer_id) as total_issuers,
    AVG(days_since_last_submission) as avg_days_since_submission,
    COUNT(CASE 
        WHEN days_since_last_submission > 30 
        THEN issuer_id 
    END) as issuers_overdue,
    COUNT(CASE 
        WHEN valid_email_contacts = 0 
        THEN issuer_id 
    END) as issuers_missing_valid_contact,
    ROUND(AVG(total_urls_submitted), 2) as avg_urls_per_issuer
FROM submission_metrics
GROUP BY state
ORDER BY issuers_overdue DESC, avg_days_since_submission DESC;

-- How It Works:
-- 1. First CTE finds the most recent submission date for each issuer in each state
-- 2. Second CTE calculates key metrics including submission age and contact validity
-- 3. Final query aggregates results by state to identify compliance patterns
-- 4. Results show states with potential compliance issues based on submission delays
--    and contact information quality

-- Assumptions and Limitations:
-- - Assumes current_date() as the reference point for timeliness
-- - Simple email validation using basic pattern matching
-- - Does not account for different submission frequency requirements
-- - Does not validate URL accessibility or content

-- Possible Extensions:
-- 1. Add trend analysis by comparing submission patterns over time
-- 2. Include URL validation checks for accessibility
-- 3. Add issuer size/market share context to prioritize follow-up
-- 4. Create compliance risk scores based on multiple factors
-- 5. Add email domain analysis to identify systematic issues
-- 6. Include seasonal patterns in submission timing

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:42:59.407042
    - Additional Notes: Query focuses on monitoring submission compliance patterns at the state level. Note that the 30-day threshold for overdue submissions is arbitrary and may need adjustment based on actual regulatory requirements. The email validation is basic and may need enhancement for production use.
    
    */