
-- Social Determinants of Health (SDoH) Tract-Level Analysis
-- Purpose: Explore income inequality, economic opportunity, and social vulnerability across US census tracts

WITH tract_economic_summary AS (
    -- Calculate key economic metrics for each tract
    SELECT 
        state,
        county,
        region,
        year,
        
        -- Income and Poverty Metrics
        acs_median_hh_inc AS median_household_income,
        acs_per_capita_inc AS per_capita_income,
        acs_gini_index AS income_inequality_index,
        
        -- Poverty and Economic Vulnerability
        acs_pct_pov_black AS black_poverty_rate,
        acs_pct_pov_white AS white_poverty_rate,
        acs_pct_pov_hispanic AS hispanic_poverty_rate,
        
        -- Economic Opportunity Indicators
        acs_pct_bachelor_dgr AS bachelors_degree_rate,
        acs_pct_unemploy AS unemployment_rate,
        
        -- Social Vulnerability Metrics
        cdcsvi_rpl_themes_all AS social_vulnerability_percentile,
        
        -- Population Context
        acs_tot_pop_wt AS total_population

    FROM 
        mimi_ws_1.ahrq.sdohdb_tract
    
    WHERE 
        territory = 0  -- Focus on U.S. States and DC
)

SELECT 
    region,
    COUNT(*) AS tract_count,
    
    -- Aggregate Economic Metrics
    ROUND(AVG(median_household_income), 2) AS avg_median_household_income,
    ROUND(AVG(per_capita_income), 2) AS avg_per_capita_income,
    ROUND(AVG(income_inequality_index), 4) AS avg_gini_index,
    
    -- Comparative Poverty Rates
    ROUND(AVG(black_poverty_rate), 2) AS avg_black_poverty_rate,
    ROUND(AVG(white_poverty_rate), 2) AS avg_white_poverty_rate,
    ROUND(AVG(hispanic_poverty_rate), 2) AS avg_hispanic_poverty_rate,
    
    -- Economic Mobility Indicators
    ROUND(AVG(bachelors_degree_rate), 2) AS avg_bachelors_degree_rate,
    ROUND(AVG(unemployment_rate), 2) AS avg_unemployment_rate,
    
    -- Social Vulnerability
    ROUND(AVG(social_vulnerability_percentile), 2) AS avg_social_vulnerability,
    
    -- Population Context
    SUM(total_population) AS total_regional_population

FROM 
    tract_economic_summary

GROUP BY 
    region

ORDER BY 
    avg_median_household_income DESC;


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:05:33.354779
    - Additional Notes: Query aggregates tract-level social determinants of health data by Census region, highlighting economic disparities across demographic groups. Requires recent, complete dataset and awareness of potential aggregation bias.
    
    */