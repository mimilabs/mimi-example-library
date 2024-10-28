
/*******************************************************************************
Title: Census Tract to ZIP Code Residential Coverage Analysis

Business Purpose:
This query analyzes the residential coverage between Census Tracts and ZIP codes
to help understand population distribution and service area planning. It identifies
ZIP codes that serve as primary residential areas for multiple Census Tracts,
which is valuable for:
- Public service delivery planning
- Retail location analysis 
- Healthcare facility placement
- Marketing campaign targeting

Key metrics:
- Number of associated Census Tracts per ZIP code
- Average residential coverage ratio
- Total residential ratio coverage
*******************************************************************************/

-- Get the most recent data snapshot
WITH latest_snapshot AS (
  SELECT MAX(mimi_src_file_date) as latest_date
  FROM mimi_ws_1.huduser.tract_to_zip
),

-- Calculate ZIP code level metrics
zip_analysis AS (
  SELECT 
    t.zip,
    t.usps_zip_pref_city,
    t.usps_zip_pref_state,
    COUNT(DISTINCT t.tract) as num_tracts,
    ROUND(AVG(t.res_ratio), 3) as avg_res_ratio,
    ROUND(SUM(t.res_ratio), 3) as total_res_ratio
  FROM mimi_ws_1.huduser.tract_to_zip t
  INNER JOIN latest_snapshot ls 
    ON t.mimi_src_file_date = ls.latest_date
  WHERE t.res_ratio > 0  -- Focus on residential areas
  GROUP BY t.zip, t.usps_zip_pref_city, t.usps_zip_pref_state
)

-- Present results ordered by coverage significance
SELECT 
  zip,
  usps_zip_pref_city,
  usps_zip_pref_state,
  num_tracts,
  avg_res_ratio,
  total_res_ratio
FROM zip_analysis
WHERE num_tracts > 1  -- Show only ZIP codes covering multiple tracts
ORDER BY total_res_ratio DESC, num_tracts DESC
LIMIT 100;

/*******************************************************************************
How the Query Works:
1. Identifies the most recent data snapshot
2. Aggregates tract-to-zip relationships at ZIP code level
3. Calculates key metrics for residential coverage
4. Filters and orders results by significance

Assumptions & Limitations:
- Uses only the most recent data snapshot
- Focuses only on residential ratios
- Assumes current relationships are valid for planning purposes
- Does not account for temporal changes in relationships

Possible Extensions:
1. Add year-over-year comparison:
   - Track changes in residential coverage patterns
   - Identify emerging population centers

2. Include business ratio analysis:
   - Compare residential vs business distribution
   - Identify mixed-use areas

3. Add geographic clustering:
   - Group nearby ZIP codes
   - Identify regional patterns

4. Demographics integration:
   - Join with Census demographic data
   - Analyze population characteristics per ZIP code

5. Service area optimization:
   - Calculate optimal service center locations
   - Determine coverage gaps
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:55:51.513044
    - Additional Notes: Query focuses on residential distribution patterns using the most recent data snapshot only. Consider adjusting the num_tracts > 1 filter and 100 row limit based on specific analysis needs. The total_res_ratio can exceed 1.0 for ZIP codes that are primary residential areas for multiple tracts.
    
    */