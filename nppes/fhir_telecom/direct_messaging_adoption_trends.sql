-- Provider Direct Message Adoption Analysis
-- Business Purpose: Analyze the adoption trends and current state of Direct messaging endpoints 
-- among healthcare providers to support interoperability initiatives and identify providers
-- who may need assistance transitioning to electronic health information exchange.

WITH current_direct_endpoints AS (
    -- Get active Direct messaging endpoints
    SELECT 
        npi,
        value AS direct_address,
        period_start,
        period_end
    FROM mimi_ws_1.nppes.fhir_telecom
    WHERE system = 'email'
    AND value LIKE '%direct.%' -- Identify Direct addresses
    AND (period_end IS NULL OR period_end > CURRENT_DATE())
),

provider_direct_stats AS (
    -- Calculate adoption metrics
    SELECT 
        YEAR(period_start) AS adoption_year,
        COUNT(DISTINCT npi) AS providers_with_direct,
        COUNT(direct_address) AS total_direct_addresses,
        COUNT(direct_address)/COUNT(DISTINCT npi) AS avg_direct_per_provider
    FROM current_direct_endpoints
    GROUP BY YEAR(period_start)
    ORDER BY adoption_year
)

SELECT 
    adoption_year,
    providers_with_direct,
    total_direct_addresses,
    ROUND(avg_direct_per_provider, 2) AS avg_direct_per_provider,
    -- Calculate year-over-year growth
    (providers_with_direct - LAG(providers_with_direct) OVER (ORDER BY adoption_year)) 
        / LAG(providers_with_direct) OVER (ORDER BY adoption_year) * 100 AS yoy_growth_pct
FROM provider_direct_stats;

-- How this query works:
-- 1. Identifies current Direct messaging endpoints from the telecom table
-- 2. Calculates yearly adoption metrics including total providers, addresses, and averages
-- 3. Computes year-over-year growth to show adoption trends

-- Assumptions and Limitations:
-- - Direct addresses are identified by '.direct.' in the email domain
-- - Only currently active endpoints are included (period_end is NULL or future)
-- - Growth calculations assume continuous provider participation
-- - Data quality depends on provider self-reporting

-- Possible Extensions:
-- 1. Add geographic analysis by joining with provider location data
-- 2. Compare Direct adoption rates across different provider specialties
-- 3. Identify providers with Direct addresses but no recent updates
-- 4. Calculate the percentage of providers in each region using Direct messaging
-- 5. Create cohorts based on adoption timing to analyze usage patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:37:25.124167
    - Additional Notes: Query focuses on Direct messaging adoption patterns within the healthcare provider network. Note that the identification of Direct addresses relies on the '.direct.' domain pattern, which may miss some valid Direct endpoints using different domain formats. Growth calculations will show as null for the first year in the dataset.
    
    */