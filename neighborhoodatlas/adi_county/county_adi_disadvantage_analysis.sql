/*
Title: County ADI Performance and Comparative Analysis
Author: Healthcare Data Analytics Team
Date: 2024-02-15

Business Purpose:
Provide a comprehensive overview of county-level socioeconomic disadvantage 
to support strategic healthcare resource allocation, policy planning, and 
targeted intervention strategies.
*/

WITH county_adi_summary AS (
    SELECT 
        fips_county,
        -- National ADI analysis
        ROUND(AVG(adi_natrank_avg), 2) AS avg_national_percentile,
        ROUND(STDDEV(adi_natrank_avg), 2) AS national_percentile_variance,
        
        -- State-specific ADI comparison
        ROUND(AVG(adi_staternk_avg), 2) AS avg_state_percentile,
        ROUND(STDDEV(adi_staternk_avg), 2) AS state_percentile_variance,
        
        -- Tracking data currency
        MAX(mimi_src_file_date) AS most_recent_data_date
    FROM 
        mimi_ws_1.neighborhoodatlas.adi_county
    GROUP BY 
        fips_county
)

SELECT 
    -- Highlight counties with highest socioeconomic disadvantage
    fips_county,
    avg_national_percentile,
    avg_state_percentile,
    
    -- Identify counties with significant internal variation
    national_percentile_variance,
    state_percentile_variance,
    
    -- Data tracking
    most_recent_data_date,
    
    -- Ranking counties by disadvantage level
    NTILE(10) OVER (ORDER BY avg_national_percentile DESC) AS national_disadvantage_decile,
    NTILE(10) OVER (ORDER BY avg_state_percentile DESC) AS state_disadvantage_decile
FROM 
    county_adi_summary
ORDER BY 
    avg_national_percentile DESC
LIMIT 100;

/*
Query Execution Notes:
- Provides a ranked view of county-level socioeconomic disadvantage
- Compares national and state-level percentile rankings
- Enables identification of high-risk counties for targeted interventions

Assumptions:
- Data represents most recent available snapshot
- Percentile rankings indicate relative socioeconomic disadvantage
- Higher percentile suggests greater socioeconomic challenges

Potential Extensions:
1. Join with healthcare utilization data
2. Correlate with chronic disease prevalence
3. Integrate with state-level health policy metrics
4. Time-series analysis of ADI changes
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:54:59.766485
    - Additional Notes: Query provides a comprehensive view of county-level socioeconomic disadvantage, focusing on national and state percentile rankings. Useful for healthcare policy planning and resource allocation strategies.
    
    */