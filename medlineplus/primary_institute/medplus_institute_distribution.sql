
/*
Title: Primary Institute Distribution Analysis for MedlinePlus Topics

Business Purpose:
This query analyzes the distribution of primary medical institutes across health topics
to understand which organizations are the key knowledge contributors and identify potential
subject matter experts or collaboration opportunities in healthcare information.

Key metrics:
- Count of topics per institute 
- Percentage share of total topics
- Recent activity based on source dates
*/

WITH institute_metrics AS (
  -- Get latest record for each topic-institute pair
  SELECT DISTINCT
    topic_id,
    institute,
    url,
    MAX(mimi_src_file_date) as latest_src_date
  FROM mimi_ws_1.medlineplus.primary_institute
  GROUP BY topic_id, institute, url
)

SELECT
  institute,
  COUNT(DISTINCT topic_id) as topic_count,
  ROUND(COUNT(DISTINCT topic_id) * 100.0 / SUM(COUNT(DISTINCT topic_id)) OVER(), 2) as topic_percentage,
  MAX(latest_src_date) as most_recent_date,
  MIN(url) as institute_url
FROM institute_metrics
GROUP BY institute
HAVING topic_count > 5  -- Focus on institutes with meaningful contribution
ORDER BY topic_count DESC
LIMIT 20;

/*
How it works:
1. CTE deduplicates to get latest record per topic-institute combination
2. Main query calculates key metrics:
   - Topic count per institute
   - Percentage share of total topics
   - Most recent source date
   - Institute URL for reference

Assumptions & Limitations:
- Uses latest source file date when multiple records exist
- Filters out institutes with 5 or fewer topics
- Limited to top 20 institutes by topic count
- Assumes institute names are standardized

Possible Extensions:
1. Add year-over-year trend analysis of institute contributions
2. Include topic categories to see institute specializations
3. Analyze geographic distribution of institutes
4. Compare URL patterns to identify organizational relationships
5. Add time-based filters for specific date ranges
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:41:19.144081
    - Additional Notes: Query focuses on active institutes (>5 topics) and includes percentage metrics for relative contribution analysis. Consider adjusting the topic count threshold (currently 5) based on specific analysis needs. URL inclusion enables direct institute reference but may increase result set size.
    
    */