-- Medicare Provider Referral Pattern Concentration Analysis
--
-- Business Purpose:
-- This analysis examines the concentration patterns of providers with different referral authorities
-- to support strategic network development by:
-- - Identifying providers with specialized vs broad referral capabilities
-- - Understanding the distribution of referral authority combinations
-- - Supporting targeted provider outreach strategies
--
-- The insights support network adequacy planning, provider engagement strategies,
-- and identification of potential gaps in referral coverage.

WITH provider_patterns AS (
    -- Calculate referral pattern combinations and their frequencies
    SELECT 
        CONCAT(
            CASE WHEN partb = 'Y' THEN 'B' ELSE '' END,
            CASE WHEN dme = 'Y' THEN 'D' ELSE '' END,
            CASE WHEN hha = 'Y' THEN 'H' ELSE '' END,
            CASE WHEN pmd = 'Y' THEN 'P' ELSE '' END,
            CASE WHEN hospice = 'Y' THEN 'S' ELSE '' END
        ) as authority_pattern,
        COUNT(*) as provider_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage
    FROM mimi_ws_1.datacmsgov.orderandreferring
    WHERE _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.orderandreferring)
    GROUP BY authority_pattern
    HAVING authority_pattern != ''  -- Exclude providers with no authorities
)

SELECT 
    authority_pattern,
    provider_count,
    ROUND(percentage, 2) as percentage,
    ROUND(SUM(percentage) OVER (ORDER BY provider_count DESC), 2) as cumulative_percentage,
    -- Create pattern description
    CASE 
        WHEN LENGTH(authority_pattern) = 5 THEN 'Full-scope provider'
        WHEN LENGTH(authority_pattern) = 1 THEN 'Single-service specialist'
        ELSE 'Multi-service provider'
    END as provider_category
FROM provider_patterns
ORDER BY provider_count DESC
LIMIT 10;

-- How this query works:
-- 1. Creates a CTE that generates a unique pattern string for each combination of referral authorities
-- 2. Calculates the frequency and percentage for each pattern
-- 3. Adds cumulative percentage and categorizes providers based on pattern breadth
-- 4. Returns the top 10 most common patterns
--
-- Assumptions and limitations:
-- - Assumes current data (uses latest _input_file_date)
-- - Limited to top 10 patterns for clarity
-- - Assumes 'Y' is the only valid positive indicator
-- - Pattern string uses first letter of each service type
--
-- Possible extensions:
-- - Add trend analysis by comparing patterns across different _input_file_dates
-- - Include geographic distribution of different patterns
-- - Create provider segments based on pattern combinations
-- - Calculate network adequacy scores based on pattern distribution
-- - Compare pattern distributions across different regions or markets

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:12:17.249621
    - Additional Notes: The query focuses on current referral authority patterns and their distribution, providing insights into provider network composition. It identifies common combinations of referral authorities and categorizes providers based on their service scope breadth. The pattern string uses a compact format where B=PartB, D=DME, H=HHA, P=PMD, S=Hospice.
    
    */