-- QPP Quality Measure Performance Analysis
-- Business Purpose: Analyze provider quality measure reporting patterns and scores
-- to identify opportunities for improving care quality and measure selection
-- across different specialties and practice types.

WITH measure_counts AS (
  SELECT
    clinician_specialty,
    practice_size,
    COUNT(DISTINCT provider_key) as provider_count,
    
    -- Calculate average number of quality measures reported
    AVG(CASE WHEN quality_measure_id_1 IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN quality_measure_id_2 IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN quality_measure_id_3 IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN quality_measure_id_4 IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN quality_measure_id_5 IS NOT NULL THEN 1 ELSE 0 END +
        CASE WHEN quality_measure_id_6 IS NOT NULL THEN 1 ELSE 0 END) as avg_measures_reported,
        
    -- Calculate average quality scores 
    AVG(quality_category_score) as avg_quality_score,
    
    -- Get most commonly reported first measure
    MODE(quality_measure_id_1) as top_measure_id
    
  FROM mimi_ws_1.datacmsgov.qpp
  WHERE nonreporting = FALSE 
    AND quality_category_score IS NOT NULL
  GROUP BY clinician_specialty, practice_size
)

SELECT
  clinician_specialty,
  practice_size,
  provider_count,
  ROUND(avg_measures_reported, 2) as avg_measures_reported,
  ROUND(avg_quality_score, 2) as avg_quality_score,
  top_measure_id
FROM measure_counts
WHERE provider_count >= 10 -- Filter for significant sample sizes
ORDER BY provider_count DESC
LIMIT 20;

/* How this query works:
1. Creates CTE to analyze quality measure reporting patterns by specialty/practice size
2. Counts distinct providers and calculates average measures reported
3. Computes average quality scores and identifies most common measures
4. Filters for groups with meaningful sample sizes
5. Returns top 20 specialty/practice size combinations by provider count

Assumptions & Limitations:
- Excludes non-reporting providers
- Only considers quality measures 1-6
- Requires minimum of 10 providers per group
- Does not account for measure weights or bonus points
- Top measure analysis limited to first reported measure

Possible Extensions:
1. Add trending over multiple years
2. Include measure-specific success rates
3. Compare performance across geographic regions
4. Analyze correlation between number of measures and scores
5. Add measure description lookups for top measures
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:23:45.576894
    - Additional Notes: Query focuses on quality measure adoption patterns and their correlation with performance scores. Note that the measure count calculations only include the first 6 quality measures, which may undercount for providers reporting more measures. Consider local performance thresholds when interpreting quality scores.
    
    */