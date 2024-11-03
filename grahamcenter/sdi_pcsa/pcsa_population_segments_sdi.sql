-- pcsa_population_analysis.sql
-- Business Purpose: Analyze PCSA population distribution and SDI scores to identify 
-- high-need large population centers that may require additional healthcare resources.
-- This helps healthcare organizations and policymakers prioritize areas where 
-- interventions could have the greatest impact.

WITH population_segments AS (
  SELECT 
    -- Segment PCSAs into population size categories
    CASE 
      WHEN pcsa_population >= 100000 THEN 'Large (100k+)'
      WHEN pcsa_population >= 50000 THEN 'Medium (50k-100k)'
      ELSE 'Small (<50k)'
    END AS population_category,
    
    -- Calculate summary statistics for each population segment
    COUNT(*) as pcsa_count,
    SUM(pcsa_population) as total_population,
    ROUND(AVG(sdi_score), 2) as avg_sdi_score,
    ROUND(AVG(pcsa_population), 0) as avg_pcsa_population,
    
    -- Identify count of high-need areas (top quartile SDI)
    SUM(CASE WHEN sdi_score >= 75 THEN 1 ELSE 0 END) as high_need_pcsa_count
    
  FROM mimi_ws_1.grahamcenter.sdi_pcsa
  WHERE mimi_src_file_date = '2019-12-31' -- Using most recent data
  GROUP BY 1
)

SELECT 
  population_category,
  pcsa_count,
  total_population,
  avg_sdi_score,
  avg_pcsa_population,
  high_need_pcsa_count,
  ROUND(high_need_pcsa_count * 100.0 / pcsa_count, 1) as pct_high_need
FROM population_segments
ORDER BY 
  CASE population_category 
    WHEN 'Large (100k+)' THEN 1 
    WHEN 'Medium (50k-100k)' THEN 2 
    ELSE 3 
  END;

/* How it works:
1. Segments PCSAs into three population size categories
2. Calculates key metrics for each segment including counts, averages, and high-need areas
3. Presents results ordered by population category size

Assumptions & Limitations:
- Uses 2019 data (most recent 5-year ACS estimates)
- Defines high-need as top quartile SDI score (75+)
- Population categories are arbitrary and may need adjustment
- Does not account for geographic distribution or proximity

Possible Extensions:
1. Add geographic grouping (state/region) to identify geographic patterns
2. Include trending analysis using multiple years of data
3. Add additional SDI component analysis within population segments
4. Incorporate distance to nearest healthcare facilities
5. Add demographic breakdowns within population segments
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:55:40.650208
    - Additional Notes: Query segments PCSAs by population size and analyzes distribution of SDI scores to identify high-need populous areas. Population thresholds (100k/50k) may need adjustment based on specific regional characteristics. Consider local demographic patterns when interpreting results.
    
    */