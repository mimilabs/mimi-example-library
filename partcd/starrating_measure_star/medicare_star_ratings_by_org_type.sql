
/*******************************************************************************
Title: Medicare Contract Star Rating Analysis By Organization Type
 
Business Purpose:
- Analyze the distribution and trends of Medicare contract star ratings across
  different organization types (HMO, PPO, etc.)
- Identify high and low performing organization types to inform quality improvement
- Support strategic decision making for Medicare Advantage program management

Created: 2024-01-20
*******************************************************************************/

-- Main query analyzing star rating performance by organization type
WITH recent_ratings AS (
  -- Get the most recent performance year data
  SELECT DISTINCT
    performance_year,
    organization_type,
    contract_id,
    measure_value::FLOAT as star_rating
  FROM mimi_ws_1.partcd.starrating_measure_star
  WHERE measure_value IS NOT NULL
    AND organization_type IS NOT NULL
    AND performance_year = (
      SELECT MAX(performance_year) 
      FROM mimi_ws_1.partcd.starrating_measure_star
    )
)

SELECT
  organization_type,
  COUNT(DISTINCT contract_id) as num_contracts,
  ROUND(AVG(star_rating), 2) as avg_star_rating,
  ROUND(MIN(star_rating), 1) as min_stars,
  ROUND(MAX(star_rating), 1) as max_stars,
  -- Calculate percentage of contracts with 4+ stars
  ROUND(100.0 * 
    SUM(CASE WHEN star_rating >= 4 THEN 1 ELSE 0 END) / 
    COUNT(*), 1
  ) as pct_4plus_stars
FROM recent_ratings
GROUP BY organization_type
ORDER BY avg_star_rating DESC;

/*******************************************************************************
How This Query Works:
1. CTE gets the most recent year's star ratings by contract and org type
2. Main query calculates key performance metrics by organization type:
   - Number of contracts
   - Average star rating
   - Min/max ratings
   - Percentage achieving 4+ stars
3. Results ordered by average rating to highlight best/worst performers

Assumptions & Limitations:
- Uses most recent performance year only
- Assumes measure_value contains overall star rating
- Excludes null values and organization types
- One rating per contract (if multiple exist, all are counted)

Possible Extensions:
1. Add year-over-year trending analysis
2. Break down by specific quality measures
3. Include geographic analysis by state/region
4. Add parent organization dimension
5. Statistical analysis of rating variations
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:42:18.159452
    - Additional Notes: Query focuses on current year performance metrics. The measure_value field should be validated to ensure it represents the overall star rating rather than individual measure scores. Results may be affected if contracts have multiple entries in the source table for the same performance year.
    
    */