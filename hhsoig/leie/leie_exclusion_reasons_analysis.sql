
/*******************************************************************************
Title: Healthcare Provider Exclusion Analysis
 
Business Purpose:
This query analyzes the List of Excluded Individuals/Entities (LEIE) to identify:
1. Most common reasons for healthcare provider exclusions
2. Geographic distribution of excluded providers
3. Trends in exclusion types
This information helps healthcare organizations manage compliance risk and understand 
exclusion patterns.
*******************************************************************************/

-- Main analysis query
WITH exclusion_summary AS (
  -- Get counts by exclusion reason and state
  SELECT 
    excl_description,
    state,
    COUNT(*) as exclusion_count,
    -- Calculate percent of total exclusions
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct_of_total
  FROM mimi_ws_1.hhsoig.leie
  WHERE excl_description IS NOT NULL 
    AND state IS NOT NULL
  GROUP BY excl_description, state
),

-- Get top 10 exclusion reasons with state aggregation
top_exclusions AS (
  SELECT 
    excl_description,
    SUM(exclusion_count) as total_exclusions,
    AVG(pct_of_total) as avg_pct,
    -- Create concatenated string of top states using collect_list
    CONCAT_WS(', ', 
      collect_list(
        CONCAT(state, '(', CAST(exclusion_count AS STRING), ')')
      )
    ) as state_breakdown
  FROM (
    SELECT 
      excl_description,
      state,
      exclusion_count,
      pct_of_total,
      ROW_NUMBER() OVER (PARTITION BY excl_description ORDER BY exclusion_count DESC) as state_rank
    FROM exclusion_summary
  ) ranked
  WHERE state_rank <= 5  -- Show top 5 states for each exclusion
  GROUP BY excl_description
)

SELECT
  excl_description,
  total_exclusions as exclusion_count,
  avg_pct as pct_of_total,
  state_breakdown as top_states
FROM top_exclusions
ORDER BY total_exclusions DESC
LIMIT 10;

/*******************************************************************************
How it works:
1. Creates summary stats for each exclusion reason and state combination
2. Calculates percentage of total exclusions
3. Ranks states within each exclusion reason
4. Shows top 5 states per exclusion reason with their counts
5. Returns top 10 exclusion reasons overall

Assumptions & Limitations:
- Focuses only on current exclusions, not historical patterns
- Assumes state and exclusion reason fields are populated
- Limited to top 10 reasons and top 5 states per reason
- State breakdown shows count per state in parentheses

Possible Extensions:
1. Add trending over time using excldate
2. Break down by provider specialty
3. Compare mandatory vs permissive exclusions
4. Add geographic visualizations
5. Analyze reinstatement patterns using reindate
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:02:51.492488
    - Additional Notes: This query provides a hierarchical view of healthcare provider exclusions, showing the top 10 exclusion reasons and their geographic distribution across states. The state breakdown is limited to top 5 states per exclusion reason to maintain readability. Results are sorted by total exclusion count to highlight the most common reasons for exclusion from federal healthcare programs.
    
    */