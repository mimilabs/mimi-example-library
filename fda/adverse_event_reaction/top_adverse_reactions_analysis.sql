-- Top Adverse Drug Reactions Analysis
--
-- Business Purpose:
-- This query analyzes the most frequently reported adverse drug reactions in the FDA database
-- to help identify safety signals and prioritize drug safety monitoring efforts.
-- Key business value includes:
-- - Early detection of emerging safety concerns
-- - Resource allocation for pharmacovigilance
-- - Support for healthcare decision-making
-- - Risk management strategy development

SELECT 
    -- Standardize reaction terms and count occurrences
    reactionmeddrapt as adverse_reaction,
    COUNT(*) as report_count,
    
    -- Calculate percentage of total reports
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct_of_total,
    
    -- Break down outcomes
    COUNT(CASE WHEN reactionoutcome = '1' THEN 1 END) as recovered,
    COUNT(CASE WHEN reactionoutcome = '2' THEN 1 END) as recovering,
    COUNT(CASE WHEN reactionoutcome = '3' THEN 1 END) as not_recovered,
    COUNT(CASE WHEN reactionoutcome = '4' THEN 1 END) as fatal,
    COUNT(CASE WHEN reactionoutcome = '5' THEN 1 END) as unknown
    
FROM mimi_ws_1.fda.adverse_event_reaction

-- Focus on recent data (last available year)
WHERE YEAR(mimi_src_file_date) = (
    SELECT MAX(YEAR(mimi_src_file_date)) 
    FROM mimi_ws_1.fda.adverse_event_reaction
)

GROUP BY reactionmeddrapt

-- Focus on significant signals
HAVING COUNT(*) >= 100

-- Order by frequency
ORDER BY report_count DESC
LIMIT 20;

-- How this query works:
-- 1. Groups adverse reactions by standardized MedDRA terms
-- 2. Counts total occurrences and calculates percentage of all reports
-- 3. Breaks down outcomes into key categories
-- 4. Filters for recent data and significant volume
-- 5. Returns top 20 most frequent reactions

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date reflects report date
-- - Limited to reactions with 100+ reports to focus on significant signals
-- - Outcome categories are predefined in FDA reporting system
-- - Does not account for potential reporting bias
-- - Does not consider drug-specific relationships

-- Possible Extensions:
-- 1. Add trend analysis by comparing against previous periods
-- 2. Join with base table to analyze by patient demographics
-- 3. Include drug-specific analysis by linking to medication data
-- 4. Add severity analysis based on outcome distributions
-- 5. Incorporate statistical significance testing
-- 6. Break down by reporting source (healthcare provider vs consumer)
-- 7. Add geographical analysis if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:24:49.821145
    - Additional Notes: Query focuses on significant adverse reactions (100+ reports) from the most recent year of data. Outcome categories (1-5) should be validated against current FDA reporting standards. Consider memory usage when running against large datasets due to window function calculations.
    
    */