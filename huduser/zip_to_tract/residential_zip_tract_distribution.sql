
/*******************************************************************************
Title: ZIP to Census Tract Geographic Distribution Analysis
 
Business Purpose:
This query analyzes the geographic distribution of residential addresses across
ZIP codes and Census tracts to help understand population density patterns and
service delivery coverage. It identifies areas with high residential concentration
which is valuable for:
- Resource allocation decisions
- Service coverage planning
- Market analysis
- Demographic studies
*******************************************************************************/

-- Get the most recent residential distribution patterns by ZIP code
WITH recent_data AS (
  SELECT DISTINCT
    zip,
    tract,
    usps_zip_pref_city,
    usps_zip_pref_state,
    res_ratio,
    tot_ratio,
    mimi_src_file_date
  FROM mimi_ws_1.huduser.zip_to_tract
  -- Get latest year's data
  WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.huduser.zip_to_tract
  )
)

SELECT 
  zip,
  usps_zip_pref_city,
  usps_zip_pref_state,
  -- Count distinct census tracts per ZIP
  COUNT(DISTINCT tract) as tract_count,
  -- Calculate concentration metrics
  ROUND(AVG(res_ratio),3) as avg_residential_ratio,
  ROUND(MAX(res_ratio),3) as max_residential_ratio,
  -- Flag ZIPs with highly concentrated residential areas
  CASE 
    WHEN MAX(res_ratio) > 0.8 THEN 'High Concentration'
    WHEN MAX(res_ratio) > 0.5 THEN 'Medium Concentration' 
    ELSE 'Dispersed'
  END as residential_pattern
FROM recent_data
GROUP BY 1,2,3
-- Focus on areas with significant residential presence
HAVING avg_residential_ratio > 0.1
ORDER BY avg_residential_ratio DESC
LIMIT 100;

/*******************************************************************************
How this query works:
1. Gets most recent snapshot of data using a CTE
2. Aggregates data at ZIP code level
3. Calculates residential concentration metrics
4. Classifies ZIPs based on residential patterns
5. Filters to focus on primarily residential areas

Assumptions and Limitations:
- Uses most recent data snapshot only
- Focus is on residential ratios as primary metric
- Simplified classification of concentration patterns
- Limited to top 100 results

Possible Extensions:
1. Add year-over-year comparison to track changes in residential patterns
2. Include business ratio analysis for commercial area identification
3. Join with demographic data for deeper population insights
4. Add geographic clustering analysis
5. Expand to include deeper tract-level analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:49:18.978944
    - Additional Notes: Query focuses on residential distribution patterns using latest available data. Note that the residential concentration thresholds (0.8 for high, 0.5 for medium) are arbitrary and may need adjustment based on specific business needs. The 0.1 filter for avg_residential_ratio excludes primarily commercial/industrial areas.
    
    */