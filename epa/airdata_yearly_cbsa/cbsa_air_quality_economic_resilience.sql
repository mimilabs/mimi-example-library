-- Title: CBSA Air Quality Economic Performance Ranking

/*
Business Purpose:
- Provide a data-driven framework for economic development and environmental sustainability
- Rank metropolitan areas based on air quality performance and stability
- Support site selection, business investment, and quality of life assessments
- Enable comparative analysis of metropolitan economic resilience through environmental lens

Target Audience:
- Economic development agencies
- Real estate investors
- Corporate site selection teams
- Urban planning departments
*/

WITH air_quality_metrics AS (
    SELECT 
        cbsa,  -- Metropolitan area name
        cbsa_code,  -- Unique identifier for metropolitan region
        year,  -- Analysis year
        
        -- Calculate percentage of good air quality days
        ROUND(good_days * 100.0 / NULLIF(days_with_aqi, 0), 2) AS pct_good_days,
        
        -- Count of problematic air quality days
        (unhealthy_days + very_unhealthy_days + hazardous_days) AS total_poor_air_days,
        
        -- Dominant pollutant assessment
        CASE 
            WHEN days_pm25 > days_ozone AND days_pm25 > days_pm10 THEN 'PM2.5'
            WHEN days_ozone > days_pm25 AND days_ozone > days_pm10 THEN 'Ozone'
            ELSE 'PM10'
        END AS primary_pollutant,
        
        max_aqi,  -- Peak air quality challenge indicator
        median_aqi  -- Typical air quality condition
    
    FROM mimi_ws_1.epa.airdata_yearly_cbsa
)

SELECT 
    cbsa,
    cbsa_code,
    year,
    pct_good_days,
    total_poor_air_days,
    primary_pollutant,
    max_aqi,
    median_aqi,
    
    -- Economic resilience score: Higher percentage of good days, lower poor air days
    ROUND(
        (pct_good_days * 0.6) - (total_poor_air_days * 0.4), 
        2
    ) AS air_quality_resilience_score

FROM air_quality_metrics

WHERE year = (SELECT MAX(year) FROM mimi_ws_1.epa.airdata_yearly_cbsa)
ORDER BY air_quality_resilience_score DESC
LIMIT 25;

/*
Query Mechanics:
- Uses Common Table Expression (CTE) for complex metric calculations
- Focuses on most recent year's data
- Creates a composite 'air quality resilience score'
- Ranks top 25 metropolitan areas by environmental performance

Assumptions:
- Most recent year represents current conditions
- Equal weighting of good days and poor air days in scoring
- Simple scoring mechanism for comparative analysis

Potential Extensions:
1. Add population data to normalize scores
2. Include multi-year trend analysis
3. Integrate economic indicators like median income or business growth
4. Create predictive models for future air quality trends
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:13:31.347005
    - Additional Notes: The query provides a ranking of metropolitan areas based on their air quality performance, with a composite resilience score. Users should be aware that the scoring mechanism is a simplified model and may require further refinement for precise economic analysis.
    
    */