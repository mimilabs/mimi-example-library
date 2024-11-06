-- Title: Provider Deactivation Compliance Risk Scoring

/*
Business Purpose:
- Assess potential compliance risks by identifying providers with unique deactivation characteristics
- Support healthcare compliance teams in prioritizing investigative resources
- Create a risk scoring mechanism for deactivated providers based on deactivation timing

Key Business Insights:
- Identify providers deactivated near critical compliance timeframes
- Establish a risk severity score based on deactivation recency
- Support proactive compliance monitoring strategies
*/

WITH provider_deactivation_risk AS (
    SELECT 
        npi,
        deactivation_date,
        -- Calculate risk score based on recency and unique deactivation patterns
        CASE 
            WHEN deactivation_date >= DATEADD(year, -1, CURRENT_DATE()) THEN 3  -- High Risk: Deactivated within last year
            WHEN deactivation_date >= DATEADD(year, -2, CURRENT_DATE()) THEN 2  -- Medium Risk: Deactivated within last 2 years
            ELSE 1  -- Low Risk: Older deactivations
        END AS deactivation_risk_score,
        
        -- Calculate days since deactivation for trend analysis
        DATEDIFF(day, deactivation_date, CURRENT_DATE()) AS days_since_deactivation
    
    FROM mimi_ws_1.nppes.deactivated
)

SELECT 
    -- Aggregate risk insights
    COUNT(DISTINCT npi) AS total_deactivated_providers,
    SUM(CASE WHEN deactivation_risk_score = 3 THEN 1 ELSE 0 END) AS high_risk_providers,
    SUM(CASE WHEN deactivation_risk_score = 2 THEN 1 ELSE 0 END) AS medium_risk_providers,
    SUM(CASE WHEN deactivation_risk_score = 1 THEN 1 ELSE 0 END) AS low_risk_providers,
    
    -- Risk distribution percentages
    ROUND(
        100.0 * SUM(CASE WHEN deactivation_risk_score = 3 THEN 1 ELSE 0 END) / 
        NULLIF(COUNT(DISTINCT npi), 0), 
    2) AS high_risk_percentage,
    
    -- Additional compliance metrics
    MIN(deactivation_date) AS earliest_deactivation,
    MAX(deactivation_date) AS latest_deactivation,
    AVG(days_since_deactivation) AS avg_days_since_deactivation

FROM provider_deactivation_risk;

/*
Query Mechanics:
- Uses Common Table Expression (CTE) to calculate provider risk scores
- Applies multi-tier risk scoring based on deactivation recency
- Provides comprehensive summary of deactivation risk distribution

Assumptions and Limitations:
- Risk scoring is based solely on deactivation date
- Does not incorporate additional context from OIG exclusions
- Assumes current date as reference point for risk calculation

Potential Extensions:
1. Integrate with OIG exclusions for more comprehensive risk assessment
2. Add geographic risk scoring by linking with provider location data
3. Create time-series trend analysis of deactivation risks
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:40:11.620063
    - Additional Notes: Risk scoring relies on deactivation date proximity and requires validation with additional compliance sources. Best used as initial screening tool for high-risk provider deactivations.
    
    */