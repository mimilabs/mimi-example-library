-- NHANES Kidney Stone Epidemiology Analysis
--
-- Business Purpose: 
-- Analyze the patterns and frequency of kidney stone occurrences among NHANES participants
-- to inform clinical guidelines, prevention strategies, and resource planning.
-- This analysis helps healthcare organizations:
-- 1. Understand the burden of kidney stones in the population
-- 2. Identify high-risk groups for targeted interventions
-- 3. Plan appropriate resource allocation for kidney stone management

SELECT 
    -- Calculate total respondents and those with kidney stone history
    COUNT(DISTINCT seqn) as total_participants,
    SUM(CASE WHEN kiq026 = 1 THEN 1 ELSE 0 END) as had_kidney_stones,
    
    -- Calculate percentage with kidney stones
    ROUND(100.0 * SUM(CASE WHEN kiq026 = 1 THEN 1 ELSE 0 END) / COUNT(DISTINCT seqn), 1) as kidney_stone_prevalence,
    
    -- Analyze recent stone passage (last 12 months)
    SUM(CASE WHEN kiq029 = 1 THEN 1 ELSE 0 END) as passed_stone_last_12mo,
    
    -- Calculate recurrence metrics for those with history
    AVG(CASE WHEN kid028 IS NOT NULL THEN kid028 ELSE NULL END) as avg_stone_episodes,
    
    -- Calculate percentage requiring medical attention in last year
    ROUND(100.0 * SUM(CASE WHEN kiq029 = 1 THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN kiq026 = 1 THEN 1 ELSE 0 END), 0), 1) as pct_active_cases,
          
    -- Add source metadata for tracking
    MIN(mimi_src_file_date) as earliest_data,
    MAX(mimi_src_file_date) as latest_data

FROM mimi_ws_1.cdc.nhanes_qre_kidney_conditions

WHERE 
    -- Ensure valid responses
    kiq026 IS NOT NULL 
    AND seqn IS NOT NULL

-- Query Implementation Notes:
-- 1. Focuses on kidney stone metrics specifically rather than general kidney conditions
-- 2. Calculates both prevalence and recurrence patterns
-- 3. Includes temporal component via 12-month passage rates
-- 4. Provides data lineage through source file dates
--
-- Assumptions and Limitations:
-- 1. Assumes survey responses are accurate and representative
-- 2. Does not account for severity or type of kidney stones
-- 3. May underestimate true prevalence due to undiagnosed cases
-- 4. Limited to self-reported data
--
-- Potential Extensions:
-- 1. Add demographic breakdowns (requires joining with demographics table)
-- 2. Include temporal trends across survey cycles
-- 3. Analyze correlation with urinary symptoms (kiq005, kiq010)
-- 4. Compare stone formation rates with dialysis needs
-- 5. Add geographic analysis if location data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:49:44.577007
    - Additional Notes: Query aggregates key kidney stone metrics including overall prevalence, recurrence rates, and recent stone passage events. Note that accurate interpretation requires understanding NHANES survey response codes where 1 typically indicates 'Yes' responses. The query intentionally excludes records with null values for key kidney stone indicators to ensure data quality.
    
    */