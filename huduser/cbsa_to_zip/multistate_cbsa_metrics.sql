-- multi_state_cbsa_analysis.sql
-- 
-- PURPOSE: Identify and analyze CBSAs that span multiple states to 
-- inform market expansion strategies and cross-state business opportunities.
-- This analysis helps organizations understand geographic areas where 
-- business operations may require multi-state coordination.

WITH current_data AS (
    -- Get most recent crosswalk data
    SELECT *
    FROM mimi_ws_1.huduser.cbsa_to_zip
    WHERE mimi_src_file_date = (
        SELECT MAX(mimi_src_file_date) 
        FROM mimi_ws_1.huduser.cbsa_to_zip
    )
),

multi_state_cbsas AS (
    -- Identify CBSAs that cross state boundaries
    SELECT 
        cbsa,
        COUNT(DISTINCT usps_zip_pref_state) as state_count,
        CONCAT_WS(', ', COLLECT_SET(usps_zip_pref_state)) as states_involved,
        COUNT(DISTINCT zip) as total_zips,
        ROUND(AVG(res_ratio * 100), 2) as avg_res_ratio_pct
    FROM current_data
    GROUP BY cbsa
    HAVING COUNT(DISTINCT usps_zip_pref_state) > 1
)

SELECT 
    m.cbsa,
    m.state_count,
    m.states_involved,
    m.total_zips,
    m.avg_res_ratio_pct as avg_residential_ratio_pct,
    COUNT(DISTINCT c.usps_zip_pref_city) as unique_cities
FROM multi_state_cbsas m
JOIN current_data c ON m.cbsa = c.cbsa
GROUP BY 
    m.cbsa,
    m.state_count,
    m.states_involved,
    m.total_zips,
    m.avg_res_ratio_pct
ORDER BY m.state_count DESC, m.total_zips DESC
LIMIT 20;

-- HOW IT WORKS:
-- 1. Identifies the most recent data using mimi_src_file_date
-- 2. Finds CBSAs that span multiple states
-- 3. Calculates key metrics for each multi-state CBSA
-- 4. Returns top 20 results ordered by number of states and ZIP codes

-- ASSUMPTIONS & LIMITATIONS:
-- - Assumes current quarter's data is most representative
-- - Limited to top 20 results for manageable analysis
-- - Does not account for seasonal variations
-- - Focus only on multi-state CBSAs

-- POSSIBLE EXTENSIONS:
-- 1. Add temporal analysis to track changes in multi-state CBSAs over time
-- 2. Include business ratio analysis for commercial opportunity assessment
-- 3. Add population or demographic data for market size estimation
-- 4. Compare residential vs business ratios across state boundaries
-- 5. Include distance calculations between ZIP codes in multi-state CBSAs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:16:00.479838
    - Additional Notes: Query identifies metropolitan areas spanning multiple states and calculates key metrics like ZIP code coverage and residential distribution. Best used for market analysis and cross-state business planning. Note that results are limited to top 20 CBSAs and use only the most recent data snapshot.
    
    */