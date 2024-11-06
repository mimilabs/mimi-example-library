-- air_quality_market_risk_analysis.sql
-- Business Purpose: Identify metropolitan areas with highest air quality volatility 
-- to support environmental health insurance product development and risk pricing

WITH aqi_volatility AS (
    -- Calculate key statistical measures of air quality variability per CBSA
    SELECT 
        cbsa,
        cbsa_code,
        COUNT(DISTINCT date) AS total_observation_days,
        ROUND(AVG(aqi), 2) AS mean_daily_aqi,
        ROUND(STDDEV(aqi), 2) AS aqi_volatility,
        MAX(CASE WHEN category = 'Unhealthy' THEN 1 ELSE 0 END) AS has_unhealthy_days,
        PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY aqi) AS aqi_95th_percentile
    FROM mimi_ws_1.epa.airdata_daily_cbsa
    WHERE date >= DATE_SUB(CURRENT_DATE, 365)  -- Last 12 months
    GROUP BY cbsa, cbsa_code
),
market_risk_scoring AS (
    -- Create a composite risk score for market targeting
    SELECT 
        *,
        ROUND(
            (aqi_volatility * 0.4) + 
            (mean_daily_aqi * 0.3) + 
            (has_unhealthy_days * 10) + 
            (aqi_95th_percentile * 0.3), 
        2) AS environmental_health_risk_score
    FROM aqi_volatility
)

-- Rank CBSAs by environmental health market risk
SELECT 
    cbsa,
    cbsa_code,
    mean_daily_aqi,
    aqi_volatility,
    environmental_health_risk_score,
    RANK() OVER (ORDER BY environmental_health_risk_score DESC) AS risk_rank
FROM market_risk_scoring
WHERE total_observation_days > 300  -- Ensure sufficient data coverage
ORDER BY environmental_health_risk_score DESC
LIMIT 25;

/*
Query Mechanics:
- Calculates air quality variability metrics for each CBSA
- Develops a composite environmental health risk score
- Identifies top 25 metropolitan areas with highest market risk

Assumptions:
- Uses most recent 12 months of data
- Risk score weighted towards volatility and peak pollution levels
- Requires at least 300 days of observations for reliable analysis

Potential Extensions:
1. Incorporate demographic data for more nuanced risk assessment
2. Add time-series forecasting of air quality trends
3. Integrate with healthcare claims data to correlate air quality with respiratory incidents
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:59:52.881462
    - Additional Notes: Calculates environmental health market risk for metropolitan areas using EPA air quality data. Risk scoring considers AQI volatility, mean pollution levels, and unhealthy air days. Designed for insurance product development and targeted risk assessment.
    
    */