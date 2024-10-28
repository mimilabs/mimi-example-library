
/*******************************************************************************
Title: Core Imaging Study Analysis - Modality and Body Site Distribution
 
Business Purpose:
This analysis provides key insights into the distribution of imaging studies
across different modalities and body sites. Understanding these patterns helps:
- Optimize resource allocation for imaging equipment
- Identify most common examination types for staffing planning
- Track utilization trends for capacity planning
*******************************************************************************/

-- Main Query
WITH study_counts AS (
  -- Calculate counts and percentages for each modality-bodysite combination
  SELECT 
    modality_description,
    bodysite_description,
    COUNT(*) as study_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
  FROM mimi_ws_1.synthea.imaging_studies
  WHERE modality_description IS NOT NULL 
    AND bodysite_description IS NOT NULL
  GROUP BY modality_description, bodysite_description
)

SELECT 
  modality_description,
  bodysite_description,
  study_count,
  percentage,
  -- Create a simple visual representation of the percentage
  REPEAT('■', CAST(percentage AS INT)) as distribution
FROM study_counts
WHERE study_count > 10  -- Filter out rare combinations
ORDER BY study_count DESC
LIMIT 15;

/*******************************************************************************
How This Query Works:
1. Creates a CTE to calculate counts and percentages for each combination
2. Filters out null values to ensure data quality
3. Adds a visual representation of the distribution
4. Limits to top 15 most common combinations

Assumptions & Limitations:
- Assumes modality and bodysite descriptions are standardized
- Limited to combinations with more than 10 occurrences
- Visual representation rounds percentages to integers
- Only shows top 15 combinations

Possible Extensions:
1. Add time-based trends:
   - Add GROUP BY YEAR(date) to see changes over time
   
2. Add patient demographics:
   - Join with patients table to analyze by age group/gender
   
3. Add geographical analysis:
   - Join with encounters table to analyze by location
   
4. Add cost analysis:
   - Join with claims/billing data to analyze cost implications
   
5. Add seasonal patterns:
   - Group by month to identify seasonal variations
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:52:18.350030
    - Additional Notes: Query focuses on high-volume imaging combinations and includes a visual distribution indicator. Filtering threshold of 10 studies may need adjustment based on data volume. Visual representation may need formatting adjustments in some SQL clients.
    
    */