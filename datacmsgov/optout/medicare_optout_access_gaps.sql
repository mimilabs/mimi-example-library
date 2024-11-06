-- Title: Medicare Opt-Out Provider Access Analysis by Patient Demographics

-- Business Purpose:
-- This query identifies areas where Medicare opt-out status may create barriers to care
-- by analyzing the relationship between provider opt-outs and local population needs.
-- The results help healthcare planners and policymakers understand where additional
-- provider recruitment or alternative care delivery strategies may be needed.

WITH current_optouts AS (
    SELECT 
        state_code,
        specialty,
        zip_code,
        -- Get the most recent status per provider
        ROW_NUMBER() OVER (PARTITION BY npi ORDER BY mimi_src_file_date DESC) as latest_record
    FROM mimi_ws_1.datacmsgov.optout
    WHERE optout_end_date > CURRENT_DATE()
),

provider_summary AS (
    SELECT 
        state_code,
        zip_code,
        specialty,
        COUNT(*) as opted_out_provider_count
    FROM current_optouts 
    WHERE latest_record = 1
    GROUP BY state_code, zip_code, specialty
),

-- Focus on top specialties with highest opt-out rates
top_specialty_impacts AS (
    SELECT
        state_code,
        specialty,
        SUM(opted_out_provider_count) as total_opted_out,
        COUNT(DISTINCT zip_code) as affected_zip_codes
    FROM provider_summary
    GROUP BY state_code, specialty
    HAVING SUM(opted_out_provider_count) > 10
)

SELECT 
    t.state_code,
    t.specialty,
    t.total_opted_out,
    t.affected_zip_codes,
    ROUND(t.total_opted_out::FLOAT / t.affected_zip_codes, 2) as avg_providers_per_zip
FROM top_specialty_impacts t
ORDER BY 
    t.total_opted_out DESC,
    t.state_code,
    t.specialty
LIMIT 20;

-- How this query works:
-- 1. Identifies currently opted-out providers using the latest status
-- 2. Aggregates providers by geography and specialty
-- 3. Calculates impact metrics including provider density per zip code
-- 4. Surfaces areas with significant opt-out concentrations

-- Assumptions and limitations:
-- 1. Uses current opt-out status only (historical trends not included)
-- 2. Does not account for total provider population in each area
-- 3. Zip code level analysis may not perfectly align with actual service areas
-- 4. Minimum threshold of 10 providers used to focus on meaningful patterns

-- Possible extensions:
-- 1. Add demographic data to identify vulnerable populations in affected areas
-- 2. Include medicare beneficiary density data for impact assessment
-- 3. Calculate distance to nearest non-opted-out provider
-- 4. Trend analysis to predict future provider availability
-- 5. Compare against total provider counts from NPPES data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:54:22.328103
    - Additional Notes: Query focuses on geographical access patterns and may need adjustment of the '10 provider' threshold based on specific regional needs. Consider adding population density data for more accurate access gap analysis.
    
    */