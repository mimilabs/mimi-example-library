-- state_metro_business_presence.sql

-- Business Purpose: Analyze the distribution of business activity across states and metropolitan areas
-- This analysis helps identify states with high concentrations of business addresses and their 
-- relationship to major metropolitan areas, which is valuable for:
-- - Market expansion planning
-- - Commercial real estate investment decisions
-- - Economic development initiatives
-- - B2B marketing strategy development

WITH state_metro_summary AS (
    -- Get the most recent data and summarize business presence by state and metro status
    SELECT 
        usps_zip_pref_state AS state,
        CASE 
            WHEN cbsa = '99999' THEN 'Non-Metro'
            ELSE 'Metro'
        END AS metro_status,
        COUNT(DISTINCT zip) as zip_count,
        -- Calculate weighted averages using business ratio
        AVG(bus_ratio) as avg_bus_ratio,
        -- Count ZIPs with significant business presence (>50% business ratio)
        SUM(CASE WHEN bus_ratio > 0.5 THEN 1 ELSE 0 END) as high_business_zips
    FROM mimi_ws_1.huduser.zip_to_cbsa
    -- Use the latest available data
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.huduser.zip_to_cbsa)
    GROUP BY 1, 2
)

SELECT 
    state,
    metro_status,
    zip_count,
    ROUND(avg_bus_ratio, 3) as avg_business_ratio,
    high_business_zips,
    ROUND(high_business_zips * 100.0 / zip_count, 1) as pct_high_business_zips
FROM state_metro_summary
WHERE zip_count >= 10  -- Filter out states with very few ZIPs
ORDER BY zip_count DESC, avg_bus_ratio DESC
LIMIT 20;

-- How the query works:
-- 1. Creates a CTE that summarizes business presence metrics by state and metropolitan status
-- 2. Uses the most recent data available in the dataset
-- 3. Calculates key metrics including ZIP counts and business concentration measures
-- 4. Returns final results with formatted metrics and practical thresholds

-- Assumptions and limitations:
-- - Assumes current data is most relevant (uses latest mimi_src_file_date)
-- - Only includes states with 10 or more ZIP codes for statistical relevance
-- - Defines "high business" areas as those with >50% business ratio
-- - Does not account for seasonal variations in business activity

-- Possible extensions:
-- 1. Add year-over-year comparison to track business concentration trends
-- 2. Include additional metrics like total_ratio for overall address density
-- 3. Break down analysis by specific CBSA codes for major metro areas
-- 4. Add correlation analysis with economic indicators
-- 5. Create geographic clusters based on business ratio patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:19:18.064683
    - Additional Notes: Query focuses on comparative business density between metropolitan and non-metropolitan areas at the state level. The threshold of 10 ZIPs per state and 50% business ratio are configurable parameters that may need adjustment based on specific analysis needs. Results are limited to top 20 entries but can be modified for full dataset analysis.
    
    */