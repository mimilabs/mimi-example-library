SELECT 
    state_name,
    county_county_equivalent,
    cbsa_title,
    metropolitan_micropolitan_statistical_area,
    central_outlying_county,
    CASE 
        WHEN metropolitan_division_code IS NOT NULL THEN 'Major Metro Division'
        WHEN csa_code IS NOT NULL THEN 'CSA Connected'
        ELSE 'Independent CBSA'
    END as metro_complexity_tier,
    COUNT(*) OVER (PARTITION BY cbsa_code) as counties_in_cbsa

FROM mimi_ws_1.census.cbsa_to_metro_div_csa
WHERE metropolitan_micropolitan_statistical_area = 'Metropolitan Statistical Area'
ORDER BY 
    state_name,
    central_outlying_county DESC,
    metro_complexity_tier,
    counties_in_cbsa DESC;

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:22:38.970538
    - Additional Notes: This query analyzes county participation in metropolitan areas by classifying counties based on their metropolitan complexity (Major Metro Division, CSA Connected, or Independent CBSA) and their role (central vs outlying). The results are organized hierarchically by state and complexity tier to highlight strategic locations for market analysis.
    
    */