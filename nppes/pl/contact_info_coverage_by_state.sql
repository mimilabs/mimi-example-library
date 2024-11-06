-- Secondary Location Phone Coverage Analysis
-- Business Purpose: Analyze the completeness and availability of contact information
-- for secondary practice locations to:
-- - Identify gaps in provider accessibility
-- - Support patient communication strategies
-- - Assess provider data quality compliance
-- This insight helps healthcare organizations improve patient access and
-- provider directory accuracy.

WITH phone_metrics AS (
    -- Calculate phone number availability metrics per state
    SELECT 
        provider_secondary_practice_location_address__state_name as state,
        COUNT(DISTINCT npi) as total_providers,
        COUNT(DISTINCT CASE 
            WHEN provider_secondary_practice_location_address__telephone_number IS NOT NULL 
            THEN npi 
        END) as providers_with_phone,
        COUNT(DISTINCT CASE 
            WHEN provider_practice_location_address__fax_number IS NOT NULL 
            THEN npi 
        END) as providers_with_fax
    FROM mimi_ws_1.nppes.pl
    WHERE provider_secondary_practice_location_address__state_name IS NOT NULL
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.nppes.pl)
    GROUP BY state
)

SELECT 
    state,
    total_providers,
    providers_with_phone,
    providers_with_fax,
    ROUND(100.0 * providers_with_phone / total_providers, 1) as phone_coverage_pct,
    ROUND(100.0 * providers_with_fax / total_providers, 1) as fax_coverage_pct
FROM phone_metrics
WHERE total_providers >= 100  -- Focus on states with meaningful sample sizes
ORDER BY total_providers DESC
LIMIT 20;

-- How this query works:
-- 1. Uses CTE to calculate base metrics per state
-- 2. Focuses on most recent data snapshot using MAX(mimi_src_file_date)
-- 3. Calculates coverage percentages for phone and fax numbers
-- 4. Filters for states with substantial provider presence
-- 5. Orders by total providers to highlight largest markets

-- Assumptions and limitations:
-- - Assumes phone/fax fields follow consistent format
-- - Does not validate phone number formatting
-- - Limited to top 20 states by provider count
-- - Does not account for historical trends

-- Possible extensions:
-- 1. Add trend analysis by comparing multiple mimi_src_file_dates
-- 2. Include phone number format validation
-- 3. Cross-reference with primary location contact info
-- 4. Add geographic clustering analysis
-- 5. Compare contact info availability between different provider types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:37:31.623980
    - Additional Notes: Query focuses on measuring provider accessibility through contact information completeness across states. For optimal insights, should be run on the latest data snapshot and may require minimum 6 months of historical data for meaningful coverage trends.
    
    */