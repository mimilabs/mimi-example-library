-- laxative_use_analysis.sql
-- Business Purpose: 
-- Analyze patterns of laxative usage across the population to understand market opportunities 
-- for pharmaceutical companies and healthcare providers in the laxative/stool softener segment.
-- This analysis helps:
-- 1. Identify potential market size for laxative products
-- 2. Understand frequency of use patterns
-- 3. Correlate laxative use with constipation reports
-- 4. Support product development and marketing strategies

WITH laxative_segments AS (
    -- Categorize laxative usage patterns
    SELECT 
        CASE 
            WHEN bhq100 = 1 THEN 'Laxative Users'
            WHEN bhq100 = 2 THEN 'Non-Users'
            ELSE 'Unknown'
        END AS usage_category,
        CASE 
            WHEN bhq110 = 1 THEN '1-2 times'
            WHEN bhq110 = 2 THEN '3-5 times'
            WHEN bhq110 = 3 THEN '6-10 times'
            WHEN bhq110 = 4 THEN '11+ times'
            ELSE 'No Usage'
        END AS frequency_category,
        CASE 
            WHEN bhq080 = 1 THEN 'Never'
            WHEN bhq080 = 2 THEN 'Rarely'
            WHEN bhq080 = 3 THEN 'Sometimes'
            WHEN bhq080 = 4 THEN 'Often'
            WHEN bhq080 = 5 THEN 'Very Often'
            ELSE 'Unknown'
        END AS constipation_frequency,
        COUNT(*) as patient_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
    FROM mimi_ws_1.cdc.nhanes_qre_bowel_health
    WHERE bhq100 IS NOT NULL
    GROUP BY 1, 2, 3
)

-- Main analysis output
SELECT 
    usage_category,
    frequency_category,
    constipation_frequency,
    patient_count,
    percentage,
    -- Calculate running totals within usage categories
    SUM(patient_count) OVER 
        (PARTITION BY usage_category ORDER BY patient_count DESC) as running_total
FROM laxative_segments
WHERE usage_category != 'Unknown'
ORDER BY 
    usage_category,
    patient_count DESC,
    frequency_category,
    constipation_frequency;

/* How this query works:
1. Creates a CTE to segment patients based on laxative usage patterns
2. Categorizes frequency of use and constipation occurrence
3. Calculates basic statistics including counts and percentages
4. Provides running totals to show cumulative market coverage

Assumptions and Limitations:
- Assumes survey responses are representative of the general population
- Limited to 30-day recall period for laxative use
- Does not account for seasonal variations
- Cannot distinguish between different types of laxatives

Possible Extensions:
1. Add demographic breakdowns (age, gender, socioeconomic status)
2. Include correlation with other bowel symptoms (bhq010-bhq040)
3. Analyze temporal trends using mimi_src_file_date
4. Add cost analysis by combining with prescription/OTC sales data
5. Segment by bowel movement frequency (bhd050) to identify high-risk groups
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:22:19.444120
    - Additional Notes: Query segments population by laxative usage and constipation frequency to identify market opportunities. Includes percentage calculations and running totals for market analysis. Best used in conjunction with demographic data for targeted market insights. Note that the analysis is limited to a 30-day window and may not capture seasonal variations in usage patterns.
    
    */