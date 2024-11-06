-- Healthcare.gov MRF Technical Contact Network Complexity Analysis
-- ================================================================
-- Business Purpose: 
-- Evaluate the technical infrastructure complexity of healthcare.gov MRF submissions 
-- by analyzing the diversity and distribution of technical points of contact across states
-- This analysis helps understand the operational sophistication of insurance issuers

WITH contact_network_metrics AS (
    SELECT 
        state,
        COUNT(DISTINCT issuer_id) AS total_issuers,
        COUNT(DISTINCT tech_poc_email) AS unique_contact_points,
        COUNT(DISTINCT SPLIT(tech_poc_email, '@')[1]) AS distinct_email_domains,
        
        -- Calculate contact point density to measure operational complexity
        ROUND(COUNT(DISTINCT tech_poc_email) * 1.0 / COUNT(DISTINCT issuer_id), 2) AS contact_point_density,
        
        -- Most recent submission date for tracking data currency
        MAX(mimi_src_file_date) AS latest_submission_date
    
    FROM mimi_ws_1.datahealthcaregov.mrf_xlsx
    WHERE tech_poc_email IS NOT NULL
    GROUP BY state
)

SELECT 
    state,
    total_issuers,
    unique_contact_points,
    distinct_email_domains,
    contact_point_density,
    latest_submission_date,
    
    -- Rank states by technical infrastructure complexity
    RANK() OVER (ORDER BY contact_point_density DESC) AS complexity_rank
FROM contact_network_metrics
ORDER BY complexity_rank
LIMIT 25;

-- Query Operational Insights
-- ---------------------------
-- How the query works:
-- 1. Aggregates MRF submission data at the state level
-- 2. Calculates metrics on issuer contacts and infrastructure
-- 3. Ranks states by contact point complexity
-- 4. Provides a snapshot of technical diversity in MRF submissions

-- Key Assumptions:
-- - Assumes email domains reflect organizational complexity
-- - Uses most recent submission date as a proxy for data currency
-- - Focuses on top 25 states by contact point density

-- Potential Extensions:
-- 1. Add time-series analysis of contact point changes
-- 2. Integrate with provider network data
-- 3. Compare contact complexity with plan diversity metrics

-- Limitations:
-- - May not capture nuanced organizational structures
-- - Depends on email domain parsing accuracy
-- - Snapshot represents a specific moment in time

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:24:58.479045
    - Additional Notes: Analyzes healthcare.gov MRF submission technical infrastructure by calculating contact point density and diversity across states. Useful for understanding operational complexity of insurance issuers, but limited by snapshot nature of data and email domain parsing assumptions.
    
    */