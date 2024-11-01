-- Title: Healthcare Provider Credential Timeline Analysis

-- Business Purpose:
-- This query analyzes the temporal patterns of healthcare provider credentials to:
-- 1. Identify providers who have maintained continuous qualification records
-- 2. Calculate the average duration of credentials
-- 3. Highlight potential gaps in credential coverage
-- This information is valuable for credentialing departments, compliance teams,
-- and healthcare organizations managing provider networks.

WITH credential_metrics AS (
    -- Calculate credential duration and identify gaps for each provider
    SELECT 
        npi,
        code_text,
        period_start,
        period_end,
        DATEDIFF(period_end, period_start) as credential_duration_days,
        LEAD(period_start) OVER (PARTITION BY npi ORDER BY period_start) as next_credential_start
    FROM mimi_ws_1.nppes.fhir_qualification
    WHERE period_start IS NOT NULL 
    AND period_end IS NOT NULL
)

SELECT 
    npi,
    COUNT(DISTINCT code_text) as total_credentials,
    MIN(period_start) as earliest_credential_date,
    MAX(period_end) as latest_credential_date,
    ROUND(AVG(credential_duration_days)/365.25, 1) as avg_credential_duration_years,
    -- Identify gaps between credentials
    SUM(CASE 
        WHEN DATEDIFF(next_credential_start, period_end) > 30 THEN 1 
        ELSE 0 
    END) as credentials_with_gaps
FROM credential_metrics
GROUP BY npi
HAVING total_credentials >= 2  -- Focus on providers with multiple credentials
ORDER BY avg_credential_duration_years DESC
LIMIT 100;

-- How it works:
-- 1. Creates a CTE to calculate credential durations and identify sequential credentials
-- 2. Aggregates metrics by provider to show their credential history
-- 3. Identifies gaps between credentials (>30 days considered a gap)
-- 4. Filters for providers with multiple credentials for meaningful analysis

-- Assumptions and Limitations:
-- 1. Assumes period_start and period_end dates are reliable when present
-- 2. 30-day gap threshold is configurable based on business needs
-- 3. Null dates are excluded from analysis
-- 4. Limited to top 100 providers by credential duration

-- Possible Extensions:
-- 1. Add specialty-specific credential analysis
-- 2. Include geographic distribution of credential patterns
-- 3. Add trend analysis to show changes in credential duration over time
-- 4. Incorporate credential type categorization for more detailed analysis
-- 5. Add alerts for providers with soon-to-expire credentials

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:30:35.257273
    - Additional Notes: Query focuses on longitudinal credential patterns and may have high computational overhead for large provider datasets. Consider adding date range filters for production use. The 30-day gap threshold and minimum credential count (2) are configurable parameters that should be adjusted based on specific organizational needs.
    
    */