/*
rhc_access_proprietary_analysis.sql

Business Purpose:
This query analyzes the rural healthcare market dynamics by examining the distribution 
of proprietary vs non-profit Rural Health Clinics (RHCs) and their service coverage 
in terms of incorporation dates and geographic presence. This helps:
- Healthcare investors evaluate market opportunities
- Policymakers assess access to care gaps
- Healthcare organizations plan market entry strategies
*/

WITH incorporated_rhcs AS (
    -- Get RHCs with valid incorporation dates to analyze market entry patterns
    SELECT 
        YEAR(incorporation_date) as inc_year,
        proprietary_nonprofit,
        state,
        COUNT(*) as num_clinics,
        COUNT(DISTINCT zip_code) as unique_zip_codes
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic
    WHERE incorporation_date IS NOT NULL
    AND proprietary_nonprofit IN ('P','N')
    GROUP BY 1,2,3
),

state_summary AS (
    -- Calculate state-level market composition metrics
    SELECT
        state,
        SUM(CASE WHEN proprietary_nonprofit = 'P' THEN num_clinics ELSE 0 END) as proprietary_count,
        SUM(CASE WHEN proprietary_nonprofit = 'N' THEN num_clinics ELSE 0 END) as nonprofit_count,
        SUM(unique_zip_codes) as total_zip_codes_served
    FROM incorporated_rhcs
    GROUP BY 1
)

SELECT 
    s.state,
    s.proprietary_count,
    s.nonprofit_count,
    s.proprietary_count * 100.0 / NULLIF((s.proprietary_count + s.nonprofit_count), 0) as proprietary_percentage,
    s.total_zip_codes_served,
    -- Calculate market concentration indicator
    CASE 
        WHEN s.proprietary_count > (2 * s.nonprofit_count) THEN 'Proprietary Dominant'
        WHEN s.nonprofit_count > (2 * s.proprietary_count) THEN 'Nonprofit Dominant'
        ELSE 'Mixed Market'
    END as market_type
FROM state_summary s
WHERE s.proprietary_count + s.nonprofit_count > 0
ORDER BY s.proprietary_count + s.nonprofit_count DESC;

/*
How it works:
1. First CTE identifies RHCs with incorporation dates and groups them by year, ownership type, and state
2. Second CTE calculates state-level metrics for market composition
3. Final query computes market dynamics indicators and ownership percentages

Assumptions & Limitations:
- Only includes RHCs with valid incorporation dates
- Assumes current ownership status reflects historical status
- Does not account for RHC closures or ownership changes
- Limited to Medicare-enrolled facilities

Possible Extensions:
1. Add temporal analysis to track market evolution over incorporation years
2. Include geographic clustering analysis using zip code data
3. Incorporate CCN data to analyze provider networks
4. Add demographic data to assess population served
5. Include owner table joins to analyze market consolidation
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:08:06.823232
    - Additional Notes: Query focuses on market share analysis between proprietary and non-profit RHCs at the state level, including geographic coverage metrics. Best used for strategic market analysis and identifying potential areas of healthcare access disparity. Note that results may be incomplete for states with a high number of RHCs missing incorporation dates.
    
    */