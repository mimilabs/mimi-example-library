-- MEPS Event File Core Measures by Category
--
-- Business Purpose: This query analyzes core expenditure and utilization measures 
-- across different medical event categories in MEPS to identify key financial and 
-- access metrics available for analysis. This supports cost analysis, utilization 
-- studies, and healthcare access research by highlighting fundamental measures.

WITH core_vars AS (
  -- Identify variables related to key measures like expenditures, visits, and access
  SELECT DISTINCT 
    category,
    varname,
    desc
  FROM mimi_ws_1.ahrq.meps_event_metadata
  WHERE 
    -- Focus on expenditure variables
    (LOWER(desc) LIKE '%expenditure%' OR 
     LOWER(desc) LIKE '%payment%' OR
     LOWER(desc) LIKE '%charge%' OR
    -- Include utilization measures  
     LOWER(desc) LIKE '%visit%' OR
     LOWER(desc) LIKE '%length of stay%' OR
    -- Add access indicators
     LOWER(desc) LIKE '%delay%' OR
     LOWER(desc) LIKE '%unable to get%')
)

SELECT
  category,
  COUNT(DISTINCT varname) as measure_count,
  -- Collect sample variables for each category
  MAX(CASE WHEN desc LIKE '%expenditure%' THEN varname END) as sample_expenditure_var,
  MAX(CASE WHEN desc LIKE '%visit%' THEN varname END) as sample_utilization_var,
  -- Include sample descriptions
  MAX(CASE WHEN desc LIKE '%expenditure%' THEN SUBSTRING(desc, 1, 100) END) as expenditure_desc,
  MAX(CASE WHEN desc LIKE '%visit%' THEN SUBSTRING(desc, 1, 100) END) as utilization_desc
FROM core_vars
GROUP BY category
ORDER BY measure_count DESC;

-- How it works:
-- 1. Creates a CTE to identify variables related to core measures using pattern matching
-- 2. Groups results by event category to show measure availability
-- 3. Provides counts and examples of core measures for each category

-- Assumptions & Limitations:
-- - Pattern matching may miss some relevant variables if descriptions use different terms
-- - Shows only one sample variable per measure type
-- - Limited to measures explicitly described in metadata

-- Possible Extensions:
-- 1. Add temporal analysis to show how core measures have evolved over time
-- 2. Create separate groupings for financial vs. utilization vs. access measures
-- 3. Cross-reference with actual data availability in event files
-- 4. Include analysis of measure data types and formats
-- 5. Add filtering for specific years or measure subcategories

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:19:50.634911
    - Additional Notes: Query identifies core financial and utilization measures across medical event categories, with sample variables and descriptions for each category type. Pattern matching approach may need adjustment based on specific research needs and actual variable naming conventions in the MEPS metadata.
    
    */