-- preventive_care_engagement_analysis.sql
-- Business Purpose:
-- Analyzes patient engagement with preventive and routine healthcare services 
-- Key insights for healthcare providers and policymakers:
-- 1. Identifies populations regularly accessing preventive care
-- 2. Highlights gaps in routine healthcare engagement
-- 3. Supports care management and population health initiatives

WITH routine_care_metrics AS (
    -- Calculate key metrics around routine care engagement
    SELECT 
        -- Group patients by general health status
        huq010 as health_status,
        
        -- Analyze routine care patterns
        COUNT(*) as total_patients,
        
        -- Calculate % with regular care provider
        SUM(CASE WHEN huq030 = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_with_usual_provider,
        
        -- Calculate % with recent provider visit (within last year)
        SUM(CASE WHEN huq06_ IN (1,2,3) THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as pct_recent_visit,
        
        -- Calculate average visits per year
        AVG(CAST(huq05_ as FLOAT)) as avg_visits_per_year
        
    FROM mimi_ws_1.cdc.nhanes_qre_hospital_utilization_access_to_care
    WHERE huq010 IS NOT NULL
    GROUP BY huq010
)

SELECT 
    CASE health_status
        WHEN 1 THEN 'Excellent'
        WHEN 2 THEN 'Very Good'
        WHEN 3 THEN 'Good'
        WHEN 4 THEN 'Fair'
        WHEN 5 THEN 'Poor'
        ELSE 'Unknown'
    END as health_status,
    total_patients,
    ROUND(pct_with_usual_provider, 1) as pct_with_usual_provider,
    ROUND(pct_recent_visit, 1) as pct_recent_visit,
    ROUND(avg_visits_per_year, 1) as avg_visits_per_year
FROM routine_care_metrics
ORDER BY health_status;

-- How this query works:
-- 1. Creates a CTE to calculate key preventive care metrics by health status
-- 2. Groups data by self-reported health status
-- 3. Calculates multiple engagement metrics including:
--    - Percentage with usual care provider
--    - Percentage with recent visits
--    - Average visits per year
-- 4. Formats results with readable health status descriptions

-- Assumptions and Limitations:
-- 1. Relies on self-reported health status and visit frequency
-- 2. Missing data is excluded from calculations
-- 3. Does not account for seasonal variations in healthcare utilization
-- 4. Visit counts may include both preventive and acute care visits

-- Possible Extensions:
-- 1. Add demographic breakdowns (age, gender, location)
-- 2. Include year-over-year trend analysis
-- 3. Compare preventive care patterns with hospitalization rates
-- 4. Analyze impact of having usual provider on visit frequency
-- 5. Include cost analysis if payment data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:53:15.563140
    - Additional Notes: Query provides comprehensive view of preventive care engagement across health status groups. Consider caching results if running frequently due to multiple aggregate calculations. May need index on huq010 column for optimal performance on large datasets.
    
    */