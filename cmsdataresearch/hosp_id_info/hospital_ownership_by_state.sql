-- Hospital Ownership Distribution Analysis Across States
-- Business Purpose: Analyze hospital ownership patterns to inform market entry strategy,
-- competitive intelligence, and healthcare policy analysis. This helps identify
-- market opportunities and understand regional competitive dynamics.

WITH ownership_stats AS (
  -- Get counts and percentages by state and control type
  SELECT 
    state,
    ctrl_type,
    COUNT(*) as hospital_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY state), 1) as pct_of_state
  FROM mimi_ws_1.cmsdataresearch.hosp_id_info
  WHERE 
    state IS NOT NULL 
    AND ctrl_type IS NOT NULL
    -- Focus on most recent fiscal year records
    AND fyb >= DATE_ADD(CURRENT_DATE(), -365)
  GROUP BY state, ctrl_type
),
state_totals AS (
  -- Get total hospitals per state for ranking
  SELECT 
    state,
    COUNT(*) as total_hospitals
  FROM mimi_ws_1.cmsdataresearch.hosp_id_info
  WHERE state IS NOT NULL
  GROUP BY state
)

SELECT 
  o.state,
  o.ctrl_type,
  o.hospital_count,
  o.pct_of_state,
  t.total_hospitals as state_total_hospitals
FROM ownership_stats o
JOIN state_totals t ON o.state = t.state
WHERE t.total_hospitals >= 20  -- Focus on states with meaningful sample size
ORDER BY t.total_hospitals DESC, o.pct_of_state DESC;

-- How this query works:
-- 1. Creates ownership_stats CTE to calculate hospital counts and percentages by state
-- 2. Creates state_totals CTE to get overall hospital counts per state
-- 3. Joins the CTEs to produce final analysis, filtering for states with 20+ hospitals
-- 4. Orders results by state size and ownership percentage

-- Assumptions & Limitations:
-- - Assumes ctrl_type values are standardized and meaningful
-- - Limited to recent fiscal year to avoid double-counting
-- - Excludes states with small hospital counts to ensure statistical relevance
-- - Does not account for hospital size/capacity differences

-- Possible Extensions:
-- 1. Add time trend analysis by comparing ownership patterns across multiple years
-- 2. Include hospital status to focus on active facilities only
-- 3. Add geographic clustering by county/region
-- 4. Cross-reference with other CMS datasets for financial performance analysis
-- 5. Add urban/rural analysis based on ZIP codes
-- 6. Compare ownership patterns in states with different regulatory environments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:47:57.911022
    - Additional Notes: The query provides state-level hospital ownership distribution analysis with a focus on states having at least 20 hospitals. It uses the most recent year of data based on fiscal year beginning dates and excludes records with null state or control type values. The percentage calculations show the proportion of each ownership type within individual states, helping identify regional patterns in healthcare facility ownership structures.
    
    */