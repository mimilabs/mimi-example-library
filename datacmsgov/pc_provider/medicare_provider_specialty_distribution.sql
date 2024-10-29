-- Medicare Provider Specialty Distribution Analysis
-- 
-- Business Purpose: Analyze the distribution of provider specialties across states to:
-- 1. Identify potential gaps in specialty coverage
-- 2. Support network adequacy planning
-- 3. Guide provider recruitment strategies
-- 4. Inform market expansion decisions

WITH provider_counts AS (
    -- Get the count of unique providers by specialty and state
    SELECT 
        state_cd,
        provider_type_desc,
        COUNT(DISTINCT npi) as provider_count,
        -- Calculate the percentage of total providers in each state
        COUNT(DISTINCT npi) * 100.0 / SUM(COUNT(DISTINCT npi)) OVER (PARTITION BY state_cd) as pct_of_state
    FROM mimi_ws_1.datacmsgov.pc_provider
    WHERE provider_type_desc IS NOT NULL 
    AND state_cd IS NOT NULL
    -- Use most recent snapshot
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.pc_provider)
    GROUP BY state_cd, provider_type_desc
),
state_rankings AS (
    -- Rank specialties within each state by provider count
    SELECT 
        state_cd,
        provider_type_desc,
        provider_count,
        pct_of_state,
        RANK() OVER (PARTITION BY state_cd ORDER BY provider_count DESC) as specialty_rank
    FROM provider_counts
)
SELECT 
    state_cd,
    provider_type_desc,
    provider_count,
    ROUND(pct_of_state, 1) as pct_of_state_providers,
    specialty_rank
FROM state_rankings
WHERE specialty_rank <= 5  -- Show top 5 specialties per state
ORDER BY state_cd, specialty_rank;

-- How this query works:
-- 1. Creates base counts of providers by state and specialty
-- 2. Calculates percentage distribution within each state
-- 3. Ranks specialties within states by provider count
-- 4. Returns top 5 specialties for each state with key metrics

-- Assumptions and Limitations:
-- 1. Uses NPI for unique provider counts (providers with multiple enrollments counted once)
-- 2. Based on most recent data snapshot only
-- 3. Excludes records with null specialty or state
-- 4. Does not account for part-time vs full-time status
-- 5. Does not consider population demographics or demand

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include geographic population data for per-capita analysis
-- 3. Add filters for specific provider types (e.g., only physicians)
-- 4. Compare specialty distribution against national averages
-- 5. Include analysis of secondary specialties
-- 6. Add provider demographics (gender distribution by specialty)
-- 7. Analyze reassignment patterns for key specialties/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:17:40.157652
    - Additional Notes: Query focuses on spatial distribution of Medicare provider specialties and may take longer to execute on large datasets. Results are sensitive to data quality in provider_type_desc field and completeness of state_cd entries. Consider adding pagination or state filters when running on full dataset.
    
    */