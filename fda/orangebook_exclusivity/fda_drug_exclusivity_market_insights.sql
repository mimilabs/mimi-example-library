-- Title: FDA Orange Book Exclusivity Analysis - Pharmaceutical Market Insights

/* 
Business Purpose:
- Analyze pharmaceutical market dynamics through FDA exclusivity grants
- Identify key trends in drug market protection and competitive positioning
- Support strategic decision-making for pharmaceutical investment and portfolio management

Key Insights:
- Understand exclusivity distribution across drug application types
- Highlight market entry barriers and potential generic competition windows
*/

WITH exclusivity_summary AS (
    SELECT 
        appl_type,
        exclusivity_code,
        COUNT(DISTINCT appl_no) AS unique_applications,
        COUNT(*) AS total_exclusivity_records,
        MIN(exclusivity_date) AS earliest_exclusivity_expiration,
        MAX(exclusivity_date) AS latest_exclusivity_expiration,
        AVG(DATEDIFF(day, CURRENT_DATE, exclusivity_date)) AS avg_days_until_expiration
    FROM 
        mimi_ws_1.fda.orangebook_exclusivity
    WHERE 
        exclusivity_date > CURRENT_DATE
    GROUP BY 
        appl_type, 
        exclusivity_code
)

SELECT 
    appl_type,
    exclusivity_code,
    unique_applications,
    total_exclusivity_records,
    earliest_exclusivity_expiration,
    latest_exclusivity_expiration,
    avg_days_until_expiration,
    ROUND(unique_applications * 100.0 / SUM(unique_applications) OVER (), 2) AS application_percent_share
FROM 
    exclusivity_summary
ORDER BY 
    unique_applications DESC
LIMIT 25;

/*
Query Mechanics:
- Aggregates exclusivity data across application types and codes
- Filters for future exclusivity periods
- Calculates key metrics including application counts and expiration windows

Assumptions:
- Uses current date as reference point for exclusivity calculations
- Assumes data represents most recent FDA Orange Book snapshot

Potential Extensions:
1. Add therapeutic area analysis by joining with additional drug classification tables
2. Create time-series view of exclusivity trends
3. Develop predictive model for generic market entry probabilities
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:44:37.737565
    - Additional Notes: Provides a comprehensive overview of FDA drug exclusivity grants, focusing on application types and market protection windows. Requires current, valid Orange Book dataset for accurate analysis.
    
    */