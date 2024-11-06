
-- Medicare Provider Referral Service Multi-Authorization Analysis
-- Business Purpose: 
-- Quantify the strategic value of providers who can refer across multiple Medicare service types
-- Provides insights for:
-- - Network development strategies
-- - Provider credentialing and network composition analysis
-- - Identifying versatile referral network contributors

WITH provider_multi_service_auth AS (
    SELECT 
        COUNT(*) as total_providers,
        SUM(CASE WHEN partb = 1 AND dme = 1 AND hha = 1 THEN 1 ELSE 0 END) as multi_service_providers,
        ROUND(
            100.0 * SUM(CASE WHEN partb = 1 AND dme = 1 AND hha = 1 THEN 1 ELSE 0 END) / 
            COUNT(*), 
            2
        ) as multi_service_percentage,
        -- Breakdown of individual service authorizations
        SUM(CASE WHEN partb = 1 THEN 1 ELSE 0 END) as part_b_providers,
        SUM(CASE WHEN dme = 1 THEN 1 ELSE 0 END) as dme_providers,
        SUM(CASE WHEN hha = 1 THEN 1 ELSE 0 END) as hha_providers,
        SUM(CASE WHEN pmd = 1 THEN 1 ELSE 0 END) as pmd_providers,
        SUM(CASE WHEN hospice = 1 THEN 1 ELSE 0 END) as hospice_providers
    FROM 
        mimi_ws_1.datacmsgov.orderandreferring
    WHERE 
        _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.orderandreferring)
)

SELECT 
    total_providers,
    multi_service_providers,
    multi_service_percentage,
    part_b_providers,
    dme_providers,
    hha_providers,
    pmd_providers,
    hospice_providers
FROM 
    provider_multi_service_auth;

-- How the Query Works:
-- 1. Uses the most recent input file date to ensure current data
-- 2. Calculates total providers and those with multi-service authorization
-- 3. Computes percentage of providers with multiple service types
-- 4. Provides count of providers authorized for each service type

-- Assumptions and Limitations:
-- - Uses most recent data snapshot
-- - Assumes binary authorization (1/0) for each service type
-- - Does not validate depth of authorization beyond presence

-- Potential Extensions:
-- 1. Add geographic segmentation of multi-service providers
-- 2. Track changes in multi-service provider composition over time
-- 3. Correlate multi-service authorization with provider specialties


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:09:06.144379
    - Additional Notes: Analyzes Medicare providers' multi-service referral capabilities, focusing on providers authorized across different service types. Provides insights into network versatility and service breadth.
    
    */