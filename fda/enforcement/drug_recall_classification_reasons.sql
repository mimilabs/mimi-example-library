
/*******************************************************************************
Title: Drug Recall Analysis by Classification and Reason
 
Business Purpose:
- Analyze FDA drug recalls to understand key quality and safety issues
- Identify most common recall reasons by severity classification
- Support quality control and risk management decisions in pharmaceutical industry

Created: 2024-02
*******************************************************************************/

-- Get top 10 recall reasons by classification with counts and percentages
WITH reason_counts AS (
  SELECT 
    classification,
    reason_for_recall,
    COUNT(*) as recall_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY classification) AS pct_of_class
  FROM mimi_ws_1.fda.enforcement
  WHERE 
    classification IN ('I', 'II', 'III') -- Focus on standard classifications
    AND reason_for_recall IS NOT NULL
  GROUP BY 
    classification,
    reason_for_recall
),
ranked_reasons AS (
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY classification ORDER BY recall_count DESC) as reason_rank
  FROM reason_counts
)
SELECT
  classification,
  reason_for_recall,
  recall_count,
  ROUND(pct_of_class, 1) as percent_of_classification
FROM ranked_reasons 
WHERE reason_rank <= 10 -- Top 10 reasons per classification
ORDER BY 
  -- Order by severity (Class I most severe) then by frequency
  CASE classification 
    WHEN 'I' THEN 1
    WHEN 'II' THEN 2 
    WHEN 'III' THEN 3
  END,
  recall_count DESC;

/*******************************************************************************
How this query works:
1. Groups recalls by classification and reason
2. Calculates count and percentage within each classification 
3. Ranks reasons within each classification by frequency
4. Returns top 10 reasons for each classification level

Assumptions & Limitations:
- Only includes recalls with standard classifications (I, II, III)
- Treats each recall equally regardless of product quantity or distribution
- Text-based reason grouping may miss similar issues with different descriptions

Possible Extensions:
1. Add trending over time to see if reasons change
2. Include product quantity for size-weighted analysis
3. Add geographic distribution patterns
4. Analyze typical time to resolution by classification
5. Compare voluntary vs mandated recall patterns
6. Add recalling firm analysis to identify repeat issues
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T13:51:34.125644
    - Additional Notes: Query focuses on recall trends by classification (severity) level. Results are ordered with most severe recalls (Class I) first. Consider memory usage if analyzing very large date ranges as the query utilizes window functions. May need date filtering for optimal performance on large datasets.
    
    */