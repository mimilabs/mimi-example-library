-- payer_ownership_distribution.sql

-- Business Purpose:
-- Analyze the distribution of insurance ownership types across the patient population to:
-- - Understand market share of different insurance ownership models
-- - Identify year-over-year shifts in insurance ownership patterns
-- - Support strategic market analysis and opportunity assessment
-- - Guide payer partnership and network development strategies

WITH yearly_ownership_counts AS (
    -- Calculate counts and percentages for each ownership type by year
    SELECT 
        start_year,
        ownership,
        COUNT(DISTINCT patient) as patient_count,
        COUNT(DISTINCT patient) * 100.0 / SUM(COUNT(DISTINCT patient)) OVER (PARTITION BY start_year) as percentage
    FROM mimi_ws_1.synthea.payer_transitions
    WHERE ownership IS NOT NULL
    GROUP BY start_year, ownership
),

ownership_trends AS (
    -- Calculate year-over-year change in market share
    SELECT 
        start_year,
        ownership,
        patient_count,
        percentage,
        percentage - LAG(percentage) OVER (PARTITION BY ownership ORDER BY start_year) as yoy_change
    FROM yearly_ownership_counts
)

SELECT 
    start_year,
    ownership,
    patient_count,
    ROUND(percentage, 2) as market_share_pct,
    ROUND(COALESCE(yoy_change, 0), 2) as market_share_change_pct
FROM ownership_trends
WHERE start_year >= 2010  -- Focus on recent years
ORDER BY start_year, market_share_pct DESC;

-- How this query works:
-- 1. First CTE calculates the distribution of ownership types for each year
-- 2. Second CTE adds year-over-year change calculations
-- 3. Final output presents key metrics with appropriate rounding
-- 4. Results are filtered to recent years for relevance

-- Assumptions and Limitations:
-- - Assumes ownership field is relatively complete and accurate
-- - Does not account for mid-year changes in ownership
-- - Market share calculations treat all patients equally (no weighting by premium or risk)
-- - Limited to available ownership categories in the data

-- Possible Extensions:
-- 1. Add geographic segmentation to analyze regional market dynamics
-- 2. Include payer-level analysis within each ownership category
-- 3. Incorporate duration of coverage as a weighting factor
-- 4. Add demographic breakdowns by age groups or other patient characteristics
-- 5. Create forecasting models based on historical ownership trends

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:47:50.626634
    - Additional Notes: This query focuses on the high-level market share trends of different insurance ownership types over time. Best used for strategic planning and market analysis. Note that the results are most meaningful when analyzed from 2010 onwards due to data completeness and relevance of trends.
    
    */