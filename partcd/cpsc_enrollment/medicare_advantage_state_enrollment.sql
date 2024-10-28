
/*******************************************************************************
Title: Medicare Advantage Enrollment Analysis by State and County

Business Purpose:
This query analyzes Medicare Advantage enrollment patterns across states and counties
to help identify market penetration, concentration, and potential opportunities.
Key business insights include:
- Geographic distribution of Medicare Advantage members
- Market size and penetration by region
- Temporal enrollment trends
*******************************************************************************/

WITH current_enrollment AS (
  -- Get the most recent enrollment data
  SELECT *
  FROM mimi_ws_1.partcd.cpsc_enrollment 
  WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.partcd.cpsc_enrollment
  )
),

state_summary AS (
  -- Summarize enrollment metrics by state
  SELECT
    state,
    COUNT(DISTINCT contract_number) as num_contracts,
    COUNT(DISTINCT plan_id) as num_plans,
    COUNT(DISTINCT county) as num_counties,
    SUM(enrollment) as total_enrollment
  FROM current_enrollment
  GROUP BY state
)

-- Generate final summary with key metrics
SELECT 
  state,
  num_contracts,
  num_plans,
  num_counties,
  total_enrollment,
  total_enrollment / num_counties as avg_enrollment_per_county,
  ROUND(100.0 * total_enrollment / SUM(total_enrollment) OVER (), 2) as pct_of_total_enrollment
FROM state_summary
WHERE total_enrollment > 0
ORDER BY total_enrollment DESC
;

/*******************************************************************************
How this query works:
1. Identifies most recent data using mimi_src_file_date
2. Calculates state-level metrics including contract and plan counts
3. Computes market share and per-county averages
4. Orders results by total enrollment

Assumptions & Limitations:
- Uses most recent month's data only
- Assumes enrollment numbers are accurate and complete
- Does not account for population differences between states
- Does not consider historical trends

Possible Extensions:
1. Add year-over-year enrollment growth analysis
2. Include county-level demographic data for deeper insights
3. Analyze market concentration using HHI calculations
4. Track plan entry/exit patterns over time
5. Compare Medicare Advantage penetration vs. Traditional Medicare
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:58:30.586406
    - Additional Notes: Query calculates key Medicare Advantage market metrics at state level using most recent data. Does not include historical trends or demographic adjustments. For accurate interpretation, results should be considered alongside state population data and Medicare eligibility statistics.
    
    */