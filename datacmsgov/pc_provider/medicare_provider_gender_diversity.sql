-- medicare_provider_gender_market_analysis.sql
-- Business Purpose: Analyze gender representation across medical specialties to:
-- 1. Identify potential diversity gaps and opportunities
-- 2. Support targeted provider recruitment strategies
-- 3. Enable gender-focused outreach programs
-- 4. Inform workforce development initiatives

WITH provider_counts AS (
    -- Get counts by specialty and gender, excluding organizations
    SELECT 
        provider_type_desc,
        gndr_sw,
        state_cd,
        COUNT(DISTINCT npi) as provider_count
    FROM mimi_ws_1.datacmsgov.pc_provider
    WHERE 
        gndr_sw IN ('F', 'M')  -- Focus on known gender categories
        AND provider_type_desc IS NOT NULL
        AND first_name IS NOT NULL  -- Exclude organizational providers
    GROUP BY 
        provider_type_desc,
        gndr_sw,
        state_cd
),

specialty_totals AS (
    -- Calculate total providers per specialty for percentage calculations
    SELECT 
        provider_type_desc,
        state_cd,
        SUM(provider_count) as total_providers
    FROM provider_counts
    GROUP BY 
        provider_type_desc,
        state_cd
)

SELECT 
    pc.provider_type_desc,
    pc.state_cd,
    SUM(CASE WHEN pc.gndr_sw = 'F' THEN pc.provider_count ELSE 0 END) as female_providers,
    SUM(CASE WHEN pc.gndr_sw = 'M' THEN pc.provider_count ELSE 0 END) as male_providers,
    st.total_providers,
    ROUND(100.0 * SUM(CASE WHEN pc.gndr_sw = 'F' THEN pc.provider_count ELSE 0 END) / st.total_providers, 1) as female_percentage,
    ROUND(100.0 * SUM(CASE WHEN pc.gndr_sw = 'M' THEN pc.provider_count ELSE 0 END) / st.total_providers, 1) as male_percentage
FROM provider_counts pc
JOIN specialty_totals st 
    ON pc.provider_type_desc = st.provider_type_desc 
    AND pc.state_cd = st.state_cd
GROUP BY 
    pc.provider_type_desc,
    pc.state_cd,
    st.total_providers
HAVING st.total_providers >= 100  -- Focus on specialties with meaningful sample sizes
ORDER BY 
    st.total_providers DESC,
    pc.state_cd
LIMIT 1000;

-- How it works:
-- 1. Creates base counts of providers by specialty, gender, and state
-- 2. Calculates total providers per specialty and state
-- 3. Joins and calculates gender percentages
-- 4. Filters for specialties with significant presence (100+ providers)

-- Assumptions and Limitations:
-- 1. Only includes individual providers (excludes organizations)
-- 2. Limited to F/M gender categories as recorded in Medicare enrollment
-- 3. Requires at least 100 providers per specialty/state for meaningful analysis
-- 4. Based on current enrollment snapshot, not historical trends

-- Possible Extensions:
-- 1. Add year-over-year trend analysis using mimi_src_file_date
-- 2. Include age demographics by linking to additional provider data
-- 3. Add geographic clustering analysis by region or metropolitan areas
-- 4. Compare gender distribution to national averages or benchmarks
-- 5. Analyze correlation with provider participation rates or patient access metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:42:22.571611
    - Additional Notes: Query provides granular gender distribution analysis at specialty/state level with built-in statistical significance threshold (100+ providers). Best used for workforce planning and DEI initiatives. Note that results are limited to binary gender categories as recorded in Medicare enrollment data.
    
    */