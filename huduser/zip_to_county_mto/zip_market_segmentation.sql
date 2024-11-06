-- Title: ZIP Code Demographic Segmentation and Market Penetration Analysis

/* 
Business Purpose:
Analyze ZIP code demographic composition and market penetration characteristics 
to support strategic business intelligence and targeted market segmentation efforts.

Key Insights:
- Understand ZIP code residential vs business address distribution
- Identify high-potential market segments
- Support geospatial market strategy development
*/

WITH zip_county_segmentation AS (
    SELECT 
        zip,
        county,
        usps_zip_pref_city,
        usps_zip_pref_state,
        
        -- Categorize ZIP codes by residential market composition
        CASE 
            WHEN res_ratio >= 0.75 THEN 'Predominantly Residential'
            WHEN res_ratio >= 0.50 THEN 'Mixed Residential'
            WHEN res_ratio < 0.50 THEN 'Commercial/Mixed Use'
        END AS residential_market_segment,
        
        -- Calculate total address volume indicators
        ROUND(res_ratio * 100, 2) AS residential_percentage,
        ROUND(bus_ratio * 100, 2) AS business_percentage,
        
        -- Market penetration scoring mechanism
        ROUND(score / score_max * 100, 2) AS market_penetration_score,
        
        -- Source metadata for traceability
        mimi_src_file_date
    FROM 
        mimi_ws_1.huduser.zip_to_county_mto
)

SELECT 
    residential_market_segment,
    COUNT(DISTINCT zip) AS unique_zip_count,
    ROUND(AVG(residential_percentage), 2) AS avg_residential_percentage,
    ROUND(AVG(business_percentage), 2) AS avg_business_percentage,
    ROUND(AVG(market_penetration_score), 2) AS avg_market_penetration_score,
    MAX(mimi_src_file_date) AS data_snapshot_date
FROM 
    zip_county_segmentation
GROUP BY 
    residential_market_segment
ORDER BY 
    unique_zip_count DESC;

/* 
Query Mechanics:
1. Segments ZIP codes based on residential composition
2. Calculates market penetration and address type distributions
3. Aggregates insights at market segment level

Assumptions:
- Uses most recent source file for analysis
- Residential ratio represents primary market characteristic
- Market penetration score indicates geographic representation strength

Potential Extensions:
- Add state-level filtering
- Incorporate additional demographic enrichment
- Create time-series tracking of market segment shifts
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:13:02.341966
    - Additional Notes: Uses zip_to_county_mto table to segment ZIP codes by residential composition and market penetration. Provides high-level overview of market characteristics across different address type distributions.
    
    */