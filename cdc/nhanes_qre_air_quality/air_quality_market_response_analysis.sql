-- Air Quality Alert Response Economic Impact Assessment

/* 
Business Purpose:
- Quantify potential market opportunities for air quality mitigation products
- Estimate economic sensitivity to environmental health warnings
- Provide insight into consumer behavior during air quality events
*/

WITH action_breakdown AS (
    SELECT 
        CASE 
            WHEN paq685 = 1 THEN 'Changed Behavior'
            ELSE 'No Changes'
        END as behavior_response,
        
        -- Multi-response action tracking
        SUM(CASE WHEN paq690a = 1 THEN 1 ELSE 0 END) as stayed_indoors,
        SUM(CASE WHEN paq690b = 1 THEN 1 ELSE 0 END) as reduced_outdoor_activity,
        SUM(CASE WHEN paq690c = 1 THEN 1 ELSE 0 END) as used_air_purifier,
        SUM(CASE WHEN paq690d = 1 THEN 1 ELSE 0 END) as wore_mask,
        
        COUNT(*) as total_respondents
    FROM 
        mimi_ws_1.cdc.nhanes_qre_air_quality
    GROUP BY 
        behavior_response
)

SELECT 
    behavior_response,
    total_respondents,
    ROUND(total_respondents * 100.0 / SUM(total_respondents) OVER (), 2) as percentage_distribution,
    stayed_indoors,
    reduced_outdoor_activity,
    used_air_purifier,
    wore_mask
FROM 
    action_breakdown
ORDER BY 
    total_respondents DESC;

/* 
Query Mechanics:
- Uses Common Table Expression (CTE) for clear, modular analysis
- Converts boolean responses to countable metrics
- Calculates percentage distribution dynamically

Assumptions:
- Data represents a representative sample
- Responses are mutually exclusive categorical data
- All boolean columns represent actual actions taken

Potential Extensions:
1. Add demographic stratification (age, gender)
2. Correlate with respiratory health indicators
3. Time-series trend analysis of behavioral responses
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:50:06.288562
    - Additional Notes: Provides insights into consumer behavior during air quality events, useful for market research in environmental health mitigation products
    
    */