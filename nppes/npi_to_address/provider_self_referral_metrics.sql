-- Healthcare Provider Self-Referral Analysis
--
-- Business Purpose:
-- Identifies providers who may be self-referring by comparing business and mailing addresses.
-- This helps identify potential conflicts of interest and compliance risks under Stark Law.
-- High rates of self-referral can indicate need for additional compliance review.

WITH provider_addresses AS (
    -- Get providers with both business and mailing addresses
    SELECT 
        npi,
        entity_type_code,
        name,
        matched_address_biz,
        matched_address_mail,
        -- Flag if business and mailing addresses match exactly
        CASE WHEN h3_r12_biz = h3_r12_mail THEN 1 ELSE 0 END as same_address,
        -- Get count of other providers at business location using array length
        ARRAY_SIZE(npi_lst_sharing_biz_addr) as biz_location_provider_count
    FROM mimi_ws_1.nppes.npi_to_address
    WHERE matched_address_biz IS NOT NULL 
    AND matched_address_mail IS NOT NULL
),

summary_stats AS (
    -- Calculate summary statistics
    SELECT
        entity_type_code,
        COUNT(*) as total_providers,
        SUM(same_address) as self_referral_count,
        ROUND(100.0 * SUM(same_address) / COUNT(*), 2) as self_referral_pct,
        AVG(biz_location_provider_count) as avg_providers_per_location
    FROM provider_addresses
    GROUP BY entity_type_code
)

SELECT
    CASE 
        WHEN entity_type_code = '1' THEN 'Individual'
        WHEN entity_type_code = '2' THEN 'Organization'
    END as provider_type,
    total_providers,
    self_referral_count,
    self_referral_pct as self_referral_percentage,
    ROUND(avg_providers_per_location, 1) as avg_providers_per_location
FROM summary_stats
ORDER BY entity_type_code;

-- How it works:
-- 1. First CTE gets all providers with valid addresses and calculates key metrics
-- 2. Second CTE aggregates data by entity type
-- 3. Final query formats results for presentation

-- Assumptions and Limitations:
-- - Assumes matching H3 indices at resolution 12 indicates same physical location
-- - Does not account for legitimate reasons for matching addresses
-- - Limited to providers with both business and mailing addresses populated
-- - Does not consider distance between addresses when they don't match exactly

-- Possible Extensions:
-- 1. Add geographic breakdown by state/region
-- 2. Include specialty analysis to identify high-risk specialties
-- 3. Add time-series analysis if historical data available
-- 4. Calculate distance between business/mailing addresses when different
-- 5. Cross-reference with claims data to validate referral patterns
-- 6. Add revenue analysis to quantify financial impact of self-referrals

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:23:08.336695
    - Additional Notes: This query analyzes potential self-referral patterns among healthcare providers by comparing business and mailing addresses. It calculates key metrics like self-referral rates and provider concentration at shared locations. Note that matching addresses don't necessarily indicate improper self-referral - legitimate scenarios like home offices or hospital-based practices may show address matches.
    
    */