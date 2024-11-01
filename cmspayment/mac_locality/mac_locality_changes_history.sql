-- MAC Locality Historical Change Analysis
-- Business Purpose: Track changes and stability in MAC locality assignments over time
-- to identify geographic areas experiencing administrative transitions and
-- potentially impacting Medicare service delivery and payment processing

WITH base_data AS (
  -- Get the latest locality assignments
  SELECT 
    mac_id,
    locality_number,
    state_abbr,
    state_name,
    mimi_src_file_date,
    LAG(mac_id) OVER (
      PARTITION BY state_abbr, locality_number 
      ORDER BY mimi_src_file_date
    ) as previous_mac_id
  FROM mimi_ws_1.cmspayment.mac_locality
  WHERE mimi_src_file_date IS NOT NULL
),

changes AS (
  -- Identify MAC assignment changes
  SELECT 
    state_name,
    state_abbr,
    locality_number,
    mac_id as current_mac_id,
    previous_mac_id,
    mimi_src_file_date as change_date
  FROM base_data
  WHERE mac_id != previous_mac_id 
  AND previous_mac_id IS NOT NULL
)

SELECT 
  state_name,
  state_abbr,
  COUNT(DISTINCT locality_number) as localities_with_changes,
  COUNT(*) as total_changes,
  MIN(change_date) as first_change_date,
  MAX(change_date) as last_change_date
FROM changes
GROUP BY state_name, state_abbr
HAVING COUNT(*) > 0
ORDER BY total_changes DESC;

-- How this query works:
-- 1. Creates base_data CTE with current and previous MAC assignments
-- 2. Identifies specific changes in changes CTE
-- 3. Summarizes changes by state with key metrics
-- 4. Filters to show only states with changes

-- Assumptions and limitations:
-- 1. Assumes mimi_src_file_date represents actual change dates
-- 2. May not capture all historical changes if data is incomplete
-- 3. Does not account for new locality creation vs reassignment

-- Possible extensions:
-- 1. Add analysis of average time between changes
-- 2. Include details about specific locality characteristics
-- 3. Compare change patterns between different MAC regions
-- 4. Correlate changes with other Medicare performance metrics
-- 5. Add geographic clustering analysis of changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:20:57.822221
    - Additional Notes: Query tracks MAC locality assignment changes over time and may require sufficient historical data in the mimi_src_file_date column for meaningful results. Performance may be impacted with very large datasets due to window functions.
    
    */