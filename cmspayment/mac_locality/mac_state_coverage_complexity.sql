-- MAC Locality State Coverage Analysis
-- Business Purpose: Analyze the geographic coverage and administrative complexity 
-- of Medicare regions by examining how many unique MAC IDs operate across states,
-- helping identify areas with potentially complex administrative coordination needs.

WITH mac_state_summary AS (
    -- Get distinct MAC-state combinations to avoid duplication from multiple localities
    SELECT DISTINCT 
        mac_id,
        state_name,
        state_abbr
    FROM mimi_ws_1.cmspayment.mac_locality
    WHERE mac_id IS NOT NULL
),

mac_coverage AS (
    -- Calculate the number of states each MAC covers
    SELECT 
        mac_id,
        COUNT(DISTINCT state_name) as states_covered,
        CONCAT_WS(', ', COLLECT_LIST(state_abbr)) as state_list
    FROM mac_state_summary
    GROUP BY mac_id
),

state_complexity AS (
    -- Calculate the number of MACs operating in each state
    SELECT 
        state_name,
        COUNT(DISTINCT mac_id) as mac_count
    FROM mac_state_summary
    GROUP BY state_name
)

-- Final output combining both perspectives
SELECT 
    mc.mac_id,
    mc.states_covered,
    mc.state_list,
    COUNT(sc.state_name) as complex_states
FROM mac_coverage mc
LEFT JOIN state_complexity sc 
    ON sc.mac_count > 1 
    AND sc.state_name IN (
        SELECT state_name 
        FROM mac_state_summary 
        WHERE mac_id = mc.mac_id
    )
GROUP BY 
    mc.mac_id,
    mc.states_covered,
    mc.state_list
ORDER BY 
    mc.states_covered DESC;

-- How this query works:
-- 1. Creates distinct MAC-state pairs to avoid locality-level duplication
-- 2. Calculates how many states each MAC serves
-- 3. Identifies states with multiple MACs operating within them
-- 4. Combines the information to show MAC coverage alongside administrative complexity

-- Assumptions and Limitations:
-- - Assumes MAC IDs are consistently recorded
-- - Does not account for temporal changes in MAC assignments
-- - Does not consider the size or population of localities
-- - May not reflect special jurisdictional arrangements

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in MAC coverage over time
-- 2. Include locality counts to measure granularity of coverage
-- 3. Join with payment data to analyze administrative costs
-- 4. Add geographic region grouping for regional analysis
-- 5. Include population data to analyze coverage relative to beneficiary counts

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:50:20.730830
    - Additional Notes: This analysis helps identify areas where Medicare administration may be more complex due to multiple MACs operating in the same states. The COLLECT_LIST function requires all state abbreviations to be non-null for proper concatenation. Consider adding error handling for null state abbreviations if data quality is a concern.
    
    */