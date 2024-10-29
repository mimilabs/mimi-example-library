-- SNF Provider Control Type Analysis Over Time
-- 
-- Business Purpose: 
-- Analyze the distribution of Skilled Nursing Facility ownership types over time
-- to understand market consolidation trends and ownership patterns.
-- This insight helps identify market opportunities and competitive dynamics.

WITH yearly_counts AS (
    -- Get counts of providers by control type for each fiscal year
    SELECT 
        YEAR(fy_bgn_dt) AS fiscal_year,
        prvdr_ctrl_type_cd,
        COUNT(DISTINCT prvdr_num) as provider_count,
        -- Calculate percentage within each year
        COUNT(DISTINCT prvdr_num) * 100.0 / SUM(COUNT(DISTINCT prvdr_num)) OVER (PARTITION BY YEAR(fy_bgn_dt)) as percentage
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_rpt
    WHERE 
        fy_bgn_dt >= '2010-01-01'
        AND prvdr_ctrl_type_cd IS NOT NULL
        -- Focus on final reports for accuracy
        AND last_rpt_sw = 'Y'
    GROUP BY 
        YEAR(fy_bgn_dt),
        prvdr_ctrl_type_cd
)

SELECT 
    fiscal_year,
    prvdr_ctrl_type_cd,
    provider_count,
    ROUND(percentage, 2) as market_share_pct,
    -- Calculate year-over-year change
    provider_count - LAG(provider_count) OVER (PARTITION BY prvdr_ctrl_type_cd ORDER BY fiscal_year) as yoy_change
FROM yearly_counts
ORDER BY 
    fiscal_year DESC,
    provider_count DESC;

-- How this query works:
-- 1. Creates a CTE to calculate yearly provider counts by control type
-- 2. Computes market share percentages within each year
-- 3. Adds year-over-year change calculations
-- 4. Orders results to show most recent years and largest providers first

-- Assumptions and Limitations:
-- - Uses fiscal year start date for temporal analysis
-- - Only includes records with valid control type codes
-- - Focuses on final report submissions only
-- - Assumes provider numbers are consistent across years

-- Possible Extensions:
-- 1. Add geographic analysis by joining with provider location data
-- 2. Include financial metrics to analyze performance by ownership type
-- 3. Create time-based forecasts of ownership trends
-- 4. Add filters for specific regions or facility sizes
-- 5. Incorporate quality metrics to compare outcomes across ownership types/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:15:53.379529
    - Additional Notes: Query aggregates provider ownership patterns and market share trends. Useful for market analysis and competitive intelligence. Limited to final report submissions after 2010 and requires valid control type codes. Performance may be impacted with very large date ranges.
    
    */