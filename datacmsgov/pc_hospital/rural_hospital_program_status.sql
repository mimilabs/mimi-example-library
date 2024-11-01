-- Hospital Conversion & Specialized Program Analysis
-- 
-- Business Purpose:
-- - Track hospital facilities converting to Rural Emergency Hospitals (REH)
-- - Analyze distribution of swing bed programs which provide flexibility between acute/skilled nursing care
-- - Support strategic planning for rural healthcare access and specialized program development
-- - Identify facilities with multiple service line capabilities

SELECT 
    state,
    -- Count total facilities
    COUNT(*) as total_hospitals,
    
    -- Track REH conversions
    SUM(CASE WHEN reh_conversion_flag = 'Y' THEN 1 ELSE 0 END) as reh_converted,
    
    -- Analyze swing bed availability
    SUM(CASE WHEN subgroup_swingbed_approved = 'Y' THEN 1 ELSE 0 END) as swingbed_programs,
    
    -- Look at multi-service facilities
    SUM(CASE WHEN 
        (COALESCE(subgroup_acute_care,'N') = 'Y') AND 
        (COALESCE(subgroup_swingbed_approved,'N') = 'Y')
    THEN 1 ELSE 0 END) as acute_plus_swingbed,
    
    -- Calculate percentages
    ROUND(100.0 * SUM(CASE WHEN reh_conversion_flag = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_reh,
    ROUND(100.0 * SUM(CASE WHEN subgroup_swingbed_approved = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_swingbed

FROM mimi_ws_1.datacmsgov.pc_hospital

WHERE state IS NOT NULL

GROUP BY state
HAVING total_hospitals >= 5  -- Filter out very small states/territories

ORDER BY total_hospitals DESC

/*
How this query works:
- Groups hospitals by state to show geographic distribution
- Calculates key metrics around REH conversion and swing bed programs
- Shows overlap between acute care and swing bed services
- Includes percentage calculations for easier comparison
- Filters out locations with very few facilities

Assumptions & Limitations:
- Relies on accurate and complete flagging of REH conversions
- May not capture facilities in process of converting
- Swing bed status is self-reported
- Does not account for temporal changes in program status

Possible Extensions:
1. Add temporal analysis by incorporating incorporation_date
2. Include rural vs urban analysis using zip codes
3. Expand to show full spectrum of service combinations
4. Add owner type analysis to understand conversion patterns
5. Include population data to calculate per-capita metrics
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:13:51.746690
    - Additional Notes: Query focuses on tracking critical transformations in rural healthcare delivery through REH conversions and swing bed programs. Performance may be impacted when analyzing states with large hospital networks. Consider adding date filters if analyzing specific timeframes or program rollouts.
    
    */