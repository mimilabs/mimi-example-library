-- Title: NHANES Smoking Cessation Treatment Analysis
-- Business Purpose:
-- - Evaluate the adoption of nicotine replacement therapy (NRT) among recent smokers
-- - Assess the timing and patterns of NRT usage relative to smoking behavior
-- - Help identify opportunities for smoking cessation intervention programs
-- - Support healthcare resource planning for smoking cessation services

WITH smoker_base AS (
    -- Identify recent smokers (past 5 days)
    SELECT 
        seqn,
        smq710 as days_smoked_past5,
        smq720 as cigs_per_day,
        CASE 
            WHEN smq725 = 1 THEN 'Today'
            WHEN smq725 = 2 THEN 'Yesterday'
            WHEN smq725 = 3 THEN '3-5 days ago'
            ELSE 'Not specified'
        END as last_cigarette
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_recent_tobacco_use
    WHERE smq690a = 1  -- Used cigarettes
),

nrt_usage AS (
    -- Analyze NRT product usage
    SELECT 
        seqn,
        smq830 as days_used_nrt,
        CASE 
            WHEN smq840 = 1 THEN 'Today'
            WHEN smq840 = 2 THEN 'Yesterday'
            WHEN smq840 = 3 THEN '3-5 days ago'
            ELSE 'Not specified'
        END as last_nrt_use
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_recent_tobacco_use
    WHERE smq690f = 1  -- Used NRT products
)

SELECT 
    -- Calculate key metrics for cessation analysis
    COUNT(DISTINCT s.seqn) as total_smokers,
    COUNT(DISTINCT n.seqn) as nrt_users,
    ROUND(COUNT(DISTINCT n.seqn) * 100.0 / NULLIF(COUNT(DISTINCT s.seqn), 0), 1) as pct_smokers_using_nrt,
    
    -- Analyze smoking intensity among NRT users vs non-users
    AVG(CASE WHEN n.seqn IS NOT NULL THEN s.cigs_per_day END) as avg_cigs_per_day_nrt_users,
    AVG(CASE WHEN n.seqn IS NULL THEN s.cigs_per_day END) as avg_cigs_per_day_non_nrt_users,
    
    -- Examine temporal patterns
    COUNT(CASE WHEN s.last_cigarette = 'Today' AND n.last_nrt_use = 'Today' THEN 1 END) as same_day_usage,
    COUNT(CASE WHEN s.last_cigarette IN ('Yesterday', '3-5 days ago') 
               AND n.last_nrt_use = 'Today' THEN 1 END) as continued_nrt_after_smoking

FROM smoker_base s
LEFT JOIN nrt_usage n ON s.seqn = n.seqn

/*
How this query works:
1. Creates a base population of recent smokers with smoking frequency data
2. Identifies NRT users and their usage patterns
3. Joins the two populations to analyze the intersection
4. Calculates key metrics for cessation treatment analysis

Assumptions and Limitations:
- Assumes cigarette smokers are the primary target for NRT
- Limited to 5-day recall period
- Does not account for long-term cessation success
- Cannot track individual progression through cessation attempts

Possible Extensions:
1. Add demographic analysis to identify populations with lower NRT adoption
2. Include other cessation methods beyond NRT
3. Analyze seasonal patterns in cessation attempts
4. Compare effectiveness of different NRT products
5. Add cost analysis for cessation treatment planning
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:37:11.400637
    - Additional Notes: Query specifically tracks NRT (Nicotine Replacement Therapy) adoption rates and patterns among recent smokers. Useful for healthcare providers and public health programs planning cessation services. Metrics include NRT usage rates, concurrent use patterns, and comparison of smoking intensity between NRT users and non-users. Five-day window limitation should be considered when interpreting results.
    
    */