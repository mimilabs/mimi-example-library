
/*******************************************************************************
Principal Cities Analysis - Core Based Statistical Areas (CBSA) Overview
*******************************************************************************/

-- Business Purpose:
-- This query provides key insights into metropolitan and micropolitan statistical areas
-- and their principal cities, helping understand the geographic distribution and
-- organization of major population centers in the United States.

-- Primary business value:
-- 1. Identify major population and economic centers
-- 2. Support regional market analysis and expansion planning
-- 3. Enable geographic segmentation for business strategy

SELECT
    -- Basic CBSA information
    cbsa_code,
    cbsa_title,
    metropolitan_micropolitan_statistical_area as area_type,
    
    -- Count principal cities per CBSA
    COUNT(DISTINCT principal_city_name) as num_principal_cities,
    
    -- List principal cities (using collect_set and concat_ws instead of STRING_AGG)
    concat_ws(', ', collect_set(principal_city_name)) as principal_cities,
    
    -- Count states spanned
    COUNT(DISTINCT fips_state_code) as num_states_spanned

FROM mimi_ws_1.census.cbsa_to_principal_city_fips

-- Get most recent data
WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.census.cbsa_to_principal_city_fips
)

GROUP BY 
    cbsa_code,
    cbsa_title, 
    metropolitan_micropolitan_statistical_area

-- Order by number of principal cities to highlight major areas
ORDER BY num_principal_cities DESC, cbsa_title;

/*******************************************************************************
HOW THIS QUERY WORKS:
- Aggregates data at the CBSA level
- Counts and lists principal cities within each CBSA
- Identifies multi-state CBSAs
- Uses most recent data based on source file date

ASSUMPTIONS & LIMITATIONS:
- Assumes most recent source file represents current CBSA definitions
- Limited to Census-designated principal cities only
- Does not account for population sizes or economic importance
- Cross-state CBSAs may have special governance considerations

POSSIBLE EXTENSIONS:
1. Add filters for specific states or regions
2. Join with population data to show size of metropolitan areas
3. Include year-over-year changes in CBSA compositions
4. Add economic indicators by joining with other census datasets
5. Create geographic clusters based on proximity of CBSAs
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:09:32.871613
    - Additional Notes: Query aggregates metropolitan and micropolitan statistical areas with their principal cities, showing multi-state regions and city counts. Results are sorted by areas with most principal cities first, using the most recent census definitions. The collect_set function may have memory limitations for very large city lists.
    
    */