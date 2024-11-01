-- Title: Medicare Provider Specialty and Group Practice Analysis

-- Business Purpose:
-- This analysis examines the distribution of medical specialties across group practices
-- to help healthcare organizations and policymakers:
-- 1. Identify specialist coverage gaps in large practices
-- 2. Understand typical group practice composition
-- 3. Support strategic planning for medical group expansion
-- 4. Analyze competition in specific markets

WITH practice_specialties AS (
    -- First aggregate specialty counts by practice
    SELECT 
        facility_name,
        org_pac_id,
        state,
        city_town,
        pri_spec,
        COUNT(DISTINCT npi) as specialist_count,
        MAX(num_org_mem) as total_practice_size
    FROM mimi_ws_1.provdatacatalog.dac_ndf
    WHERE facility_name IS NOT NULL 
    AND org_pac_id IS NOT NULL
    GROUP BY 
        facility_name,
        org_pac_id,
        state,
        city_town,
        pri_spec
),

practice_summary AS (
    -- Calculate specialty mix for larger practices
    SELECT 
        facility_name,
        state,
        city_town,
        total_practice_size,
        COUNT(DISTINCT pri_spec) as number_of_specialties,
        CONCAT_WS(', ', 
            COLLECT_LIST(CONCAT(pri_spec, ': ', CAST(specialist_count AS STRING)))
        ) as specialty_composition
    FROM practice_specialties
    WHERE total_practice_size >= 50  -- Focus on larger practices
    GROUP BY 
        facility_name,
        state,
        city_town,
        total_practice_size
)

SELECT 
    facility_name,
    state,
    city_town,
    total_practice_size,
    number_of_specialties,
    specialty_composition
FROM practice_summary
ORDER BY total_practice_size DESC
LIMIT 100;

-- How it works:
-- 1. First CTE aggregates providers by specialty within each practice
-- 2. Second CTE summarizes the specialty mix for larger practices
-- 3. Final output shows the largest practices with their specialty composition

-- Assumptions and Limitations:
-- 1. Focuses only on practices with 50+ providers
-- 2. Assumes primary specialty is the main indicator of provider type
-- 3. Does not account for part-time providers
-- 4. May include outdated information based on data refresh frequency

-- Possible Extensions:
-- 1. Add geographic analysis to identify regional specialty gaps
-- 2. Compare specialty mix across different practice size tiers
-- 3. Analyze year-over-year changes in practice composition
-- 4. Include secondary specialties in the analysis
-- 5. Add filters for specific specialty types of interest
-- 6. Calculate market concentration metrics by specialty and region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:24:57.496135
    - Additional Notes: Query focuses on medical practices with 50+ providers and analyzes their specialty composition. Results show top 100 largest practices with detailed breakdown of specialties. Uses CONCAT_WS and COLLECT_LIST functions which are Spark SQL specific - may need adjustment for other SQL dialects.
    
    */