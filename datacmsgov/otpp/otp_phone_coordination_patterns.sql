-- OTP Provider Service Hours Analysis for Care Coordination
--
-- Business Purpose:
-- - Identify providers' availability through phone access patterns
-- - Support care coordination by understanding provider accessibility
-- - Enable more effective patient referrals based on provider availability
-- - Help identify potential gaps in after-hours coverage

WITH phone_patterns AS (
    SELECT 
        state,
        -- Extract area code from phone number
        SUBSTRING(REPLACE(phone, '-', ''), 1, 3) as area_code,
        COUNT(*) as provider_count,
        -- Flag if phone follows standard business format (XXX-XXX-XXXX)
        COUNT(CASE WHEN phone LIKE '___-___-____' THEN 1 END) as standard_format_count,
        -- Count unique phone numbers to identify shared lines
        COUNT(DISTINCT phone) as unique_phones
    FROM mimi_ws_1.datacmsgov.otpp
    WHERE phone IS NOT NULL
    GROUP BY state, SUBSTRING(REPLACE(phone, '-', ''), 1, 3)
)

SELECT 
    state,
    area_code,
    provider_count,
    standard_format_count,
    unique_phones,
    -- Calculate percentage of providers sharing phone numbers
    ROUND(100.0 * (provider_count - unique_phones) / provider_count, 2) as shared_line_pct
FROM phone_patterns
WHERE provider_count > 1  -- Focus on areas with multiple providers
ORDER BY 
    shared_line_pct DESC,
    provider_count DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to analyze phone number patterns by state and area code
-- 2. Calculates counts of providers and unique phone numbers
-- 3. Identifies areas where providers share phone lines
-- 4. Focuses on locations with multiple providers to identify coordination patterns

-- Assumptions and Limitations:
-- - Assumes phone numbers are generally formatted consistently
-- - Limited to analyzing explicit phone sharing, not call forwarding or other arrangements
-- - Does not capture after-hours arrangements or scheduling details
-- - May not reflect recent changes in provider contact information

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in provider contact patterns
-- 2. Cross-reference with provider enrollment dates to identify evolving coordination
-- 3. Include ZIP code level analysis for more granular geographic insights
-- 4. Compare phone sharing patterns between urban and rural areas
-- 5. Analyze correlation between shared lines and provider proximity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:11:55.889888
    - Additional Notes: Query analyzes phone number sharing patterns among OTP providers to identify potential care coordination networks and service coverage arrangements. Results may need validation as shared phone numbers could also indicate administrative consolidation or data quality issues rather than actual service coordination.
    
    */