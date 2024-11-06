
-- Medicare Shared Savings Program (MSSP) County Expenditure Performance Analysis
-- Author: Healthcare Data Analytics Team
-- Purpose: Analyze county-level Medicare expenditure and risk metrics across enrollment types
-- Business Value: Identify high-cost counties and understand risk stratification for targeted interventions

WITH county_performance AS (
    SELECT 
        year,
        state_name,
        county_name,
        
        -- Calculate total per capita expenditures across enrollment types
        ROUND(
            per_capita_exp_esrd * person_years_esrd +
            per_capita_exp_dis * person_years_dis +
            per_capita_exp_agdu * person_years_agdu +
            per_capita_exp_agnd * person_years_agnd, 2
        ) AS total_county_expenditure,
        
        -- Weighted average risk scores
        ROUND(
            (avg_risk_score_esrd * person_years_esrd +
             avg_risk_score_dis * person_years_dis +
             avg_risk_score_agdu * person_years_agdu +
             avg_risk_score_agnd * person_years_agnd) / 
            (person_years_esrd + person_years_dis + person_years_agdu + person_years_agnd), 2
        ) AS weighted_avg_risk_score,
        
        -- Total beneficiary person-years
        (person_years_esrd + person_years_dis + person_years_agdu + person_years_agnd) AS total_person_years
    
    FROM mimi_ws_1.datacmsgov.mssp_county_lvl_expenditures
)

SELECT 
    year,
    state_name,
    county_name,
    total_county_expenditure,
    weighted_avg_risk_score,
    total_person_years,
    
    -- Identify counties in top 10% of expenditures
    PERCENT_RANK() OVER (PARTITION BY year ORDER BY total_county_expenditure DESC) AS expenditure_percentile

FROM county_performance

WHERE year = (SELECT MAX(year) FROM mimi_ws_1.datacmsgov.mssp_county_lvl_expenditures)
    AND total_person_years > 100  -- Filter out counties with minimal data
ORDER BY total_county_expenditure DESC
LIMIT 50;

-- Query Methodology:
-- 1. Calculate total county-level expenditures across all enrollment types
-- 2. Compute weighted average risk scores
-- 3. Identify high-expenditure counties using percentile ranking
-- 4. Filter for most recent year and counties with meaningful data

-- Potential Business Insights:
-- - Identify counties with disproportionately high Medicare expenditures
-- - Understand relationship between risk scores and total spending
-- - Target interventions in high-cost, high-risk counties

-- Possible Query Extensions:
-- 1. Trend analysis across multiple years
-- 2. State-level aggregations
-- 3. Enrollment type-specific deep dives
-- 4. Correlation analysis between risk scores and expenditures


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:47:54.688297
    - Additional Notes: Requires filtering for most recent year and assumes sufficient sample size (>100 person-years). Uses percentile ranking to highlight high-expenditure counties across Medicare enrollment types.
    
    */