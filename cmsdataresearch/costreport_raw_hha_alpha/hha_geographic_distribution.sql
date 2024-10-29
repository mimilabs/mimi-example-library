-- identify_hha_geographic_patterns.sql

/* 
Business Purpose:
This query analyzes the geographic distribution and concentration of Home Health Agencies
by extracting location information from cost reports. Understanding geographic patterns
helps identify market opportunities, underserved areas, and potential consolidation targets.

Key business applications:
- Market entry and expansion planning
- Competitive intelligence
- M&A target identification
- Network adequacy analysis
*/

WITH location_data AS (
    -- Extract state and city information from worksheets containing provider details
    SELECT DISTINCT
        rpt_rec_num,
        MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '00100' THEN itm_alphnmrc_itm_txt END) AS provider_state,
        MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '00200' THEN itm_alphnmrc_itm_txt END) AS provider_city
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_alpha
    WHERE wksht_cd = 'S200001' 
    AND line_num IN ('00100', '00200')
    GROUP BY rpt_rec_num
),

agency_counts AS (
    -- Calculate HHA concentration by state and city
    SELECT 
        provider_state,
        provider_city,
        COUNT(DISTINCT rpt_rec_num) as num_agencies,
        ROUND(COUNT(DISTINCT rpt_rec_num) * 100.0 / SUM(COUNT(DISTINCT rpt_rec_num)) OVER (PARTITION BY provider_state), 2) as pct_of_state
    FROM location_data
    WHERE provider_state IS NOT NULL
    GROUP BY provider_state, provider_city
)

-- Generate final geographic analysis
SELECT 
    provider_state,
    provider_city,
    num_agencies,
    pct_of_state as pct_agencies_in_state,
    RANK() OVER (PARTITION BY provider_state ORDER BY num_agencies DESC) as city_rank_in_state
FROM agency_counts
WHERE provider_city IS NOT NULL
ORDER BY provider_state, num_agencies DESC;

/*
How it works:
1. First CTE extracts state and city data from the S200001 worksheet
2. Second CTE calculates agency counts and percentages by location
3. Final query ranks cities within each state by agency concentration

Assumptions & Limitations:
- Assumes location data is consistently recorded in worksheet S200001
- May not capture agencies with multiple locations
- Historical data may include closed facilities
- Geographic patterns may not reflect current market conditions

Possible Extensions:
1. Add temporal analysis to track market evolution over time
2. Include ownership type analysis by geography
3. Incorporate demographic data to calculate penetration rates
4. Add distance calculations between agencies for competition analysis
5. Include financial metrics to identify high-performing markets
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:14:16.660540
    - Additional Notes: Query expects worksheet code S200001 to contain provider location data in standardized format. Results may be incomplete if location fields are inconsistently populated across different reporting periods or provider types.
    
    */