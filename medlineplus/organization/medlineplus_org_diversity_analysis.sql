-- Title: MedlinePlus Organization Diversity and Content Source Analysis

/*
Business Purpose:
- Quantify the unique organizational landscape contributing to MedlinePlus
- Provide insights into content source diversity and concentration
- Support strategic decision-making for content partnership and expansion

Primary Business Questions Answered:
1. How many unique organizations contribute to MedlinePlus?
2. What is the distribution of organizational contributions?
3. How stable are organizational data sources over time?
*/

WITH org_summary AS (
    SELECT 
        organization,  -- Capture unique organization names
        COUNT(DISTINCT site_id) AS site_count,  -- Count distinct sites per organization
        MIN(mimi_src_file_date) AS first_contribution_date,
        MAX(mimi_src_file_date) AS latest_contribution_date,
        COUNT(DISTINCT mimi_src_file_date) AS contribution_periods
    FROM mimi_ws_1.medlineplus.organization
    GROUP BY organization
)

SELECT 
    organization,
    site_count,
    first_contribution_date,
    latest_contribution_date,
    contribution_periods,
    ROUND(site_count * 100.0 / (SELECT COUNT(DISTINCT site_id) FROM mimi_ws_1.medlineplus.organization), 2) AS site_coverage_pct
FROM org_summary
ORDER BY site_count DESC
LIMIT 50;

/*
Query Mechanics:
- Uses Common Table Expression (CTE) for organizational analysis
- Aggregates data at organization level
- Calculates site coverage percentage
- Sorts by most contributing organizations

Assumptions:
- Site_id represents unique content sources
- Organizations can contribute across multiple sites
- More sites indicate broader organizational involvement

Potential Extensions:
1. Time-series analysis of organizational contributions
2. Correlation with content quality metrics
3. Geographical mapping of organizational sources

Performance Considerations:
- Query is read-only and uses aggregation
- Suitable for dashboard or periodic reporting
- Can be easily parameterized for specific date ranges
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:40:57.694888
    - Additional Notes: Provides high-level overview of organizational contributions to MedlinePlus, focusing on site coverage, contribution periods, and organizational involvement. Useful for strategic content sourcing insights.
    
    */