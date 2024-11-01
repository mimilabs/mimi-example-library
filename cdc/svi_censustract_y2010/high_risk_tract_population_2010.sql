-- Title: High-Risk Census Tracts and Population Impact Analysis (2010)

-- Business Purpose:
-- This query identifies census tracts with multiple high-risk factors (90th percentile)
-- and quantifies the total population affected. This information is crucial for:
-- - Emergency preparedness and resource allocation
-- - Public health intervention planning
-- - Grant funding prioritization
-- - Community support program targeting

SELECT 
    state_name,
    county,
    -- Count tracts with multiple risk factors
    COUNT(DISTINCT fips) as high_risk_tracts,
    
    -- Sum total population in high-risk tracts
    SUM(totpop) as affected_population,
    
    -- Calculate average risk scores for key themes
    ROUND(AVG(r_pl_theme1), 2) as avg_socioeconomic_risk,
    ROUND(AVG(r_pl_theme2), 2) as avg_household_comp_risk,
    ROUND(AVG(r_pl_theme3), 2) as avg_minority_lang_risk,
    ROUND(AVG(r_pl_theme4), 2) as avg_housing_transp_risk,
    
    -- Flag combinations indicating severe vulnerability
    SUM(CASE WHEN f_pl_total >= 3 THEN 1 ELSE 0 END) as tracts_with_3plus_flags

FROM mimi_ws_1.cdc.svi_censustract_y2010

-- Focus on tracts with multiple high-risk factors
WHERE f_pl_total >= 2  -- At least 2 theme flags present
AND totpop > 0  -- Exclude unpopulated areas

GROUP BY 
    state_name,
    county

-- Focus on areas with significant impact
HAVING SUM(totpop) >= 10000

-- Order by most affected areas first
ORDER BY affected_population DESC
LIMIT 100;

-- How it works:
-- 1. Identifies census tracts where multiple vulnerability flags are present
-- 2. Aggregates population and risk scores at county level
-- 3. Focuses on areas with substantial affected population (10,000+)
-- 4. Provides a ranked list of counties with most vulnerable populations

-- Assumptions and Limitations:
-- - Assumes current population distribution matches 2010 census
-- - Equal weighting given to all vulnerability flags
-- - May not capture rapid demographic changes since 2010
-- - Minimum population threshold may exclude some rural areas

-- Possible Extensions:
-- 1. Add year-over-year comparison with more recent SVI data
-- 2. Include specific risk factors (poverty, transportation, etc.)
-- 3. Add geographic clustering analysis
-- 4. Incorporate additional demographic or health outcome data
-- 5. Create risk-weighted scoring system based on local priorities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:24:17.227243
    - Additional Notes: The query focuses on population impact in census tracts with multiple vulnerability flags. The threshold of 10,000 minimum population and requirement of 2+ risk flags may need adjustment based on specific use cases. Results are most relevant for urban and suburban areas due to population requirements.
    
    */