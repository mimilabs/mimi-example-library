
/*******************************************************************************
Title: Core Analysis of NHANES Biochemistry Profiles
 
Business Purpose:
- Analyze key biochemical markers from the NHANES study to understand population health
- Focus on liver function tests (ALT, AST) and metabolic indicators (glucose, cholesterol)
- Provide baseline statistics to identify potential health risks and trends
*******************************************************************************/

WITH biochem_stats AS (
  -- Calculate basic statistics for key biomarkers
  SELECT
    -- Basic statistics for liver enzymes
    COUNT(*) as total_records,
    ROUND(AVG(lbxsatsi), 1) as avg_alt,
    ROUND(STDDEV(lbxsatsi), 1) as std_alt,
    ROUND(AVG(lbxsassi), 1) as avg_ast,
    
    -- Metabolic indicators
    ROUND(AVG(lbxsgl), 1) as avg_glucose_mgdl,
    ROUND(AVG(lbxsch1), 1) as avg_cholesterol_mgdl,
    
    -- Liver function markers
    ROUND(AVG(lbxstb), 2) as avg_bilirubin_mgdl,
    ROUND(AVG(lbxsapsi), 1) as avg_alk_phos
  FROM mimi_ws_1.cdc.nhanes_lab_standard_biochemistry_profile
  WHERE 
    -- Filter out null values and potential errors
    lbxsatsi IS NOT NULL 
    AND lbxsassi IS NOT NULL
    AND lbxsgl IS NOT NULL
),

abnormal_values AS (
  -- Calculate percentage of samples with elevated markers
  SELECT
    ROUND(100.0 * COUNT(CASE WHEN lbxsatsi > 40 THEN 1 END) / COUNT(*), 1) as pct_elevated_alt,
    ROUND(100.0 * COUNT(CASE WHEN lbxsassi > 40 THEN 1 END) / COUNT(*), 1) as pct_elevated_ast,
    ROUND(100.0 * COUNT(CASE WHEN lbxsgl > 100 THEN 1 END) / COUNT(*), 1) as pct_elevated_glucose
  FROM mimi_ws_1.cdc.nhanes_lab_standard_biochemistry_profile
  WHERE lbxsatsi IS NOT NULL AND lbxsassi IS NOT NULL AND lbxsgl IS NOT NULL
)

-- Combine the statistics into a summary report
SELECT 
  b.total_records,
  b.avg_alt,
  b.std_alt,
  a.pct_elevated_alt,
  b.avg_ast,
  a.pct_elevated_ast,
  b.avg_glucose_mgdl,
  a.pct_elevated_glucose,
  b.avg_cholesterol_mgdl,
  b.avg_bilirubin_mgdl,
  b.avg_alk_phos
FROM biochem_stats b
CROSS JOIN abnormal_values a;

/*******************************************************************************
How this query works:
1. First CTE calculates average values and standard deviations for key biomarkers
2. Second CTE determines percentage of samples with elevated values
3. Final SELECT combines these metrics into a single row summary

Assumptions and Limitations:
- Uses standard clinical thresholds for "elevated" values
- Excludes null values which could bias results
- Does not account for demographic factors or time trends
- Simple averages may mask important population subgroups

Possible Extensions:
1. Add demographic breakdowns (would need to join with demographics table)
2. Analyze trends over time using mimi_src_file_date
3. Calculate correlations between different biomarkers
4. Add risk stratification based on multiple markers
5. Compare against clinical reference ranges by age/sex
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:03:19.453174
    - Additional Notes: Query focuses on key biochemical markers (liver enzymes, glucose, cholesterol) but requires data quality checks before production use. Reference ranges for 'elevated' values may need adjustment based on specific population characteristics. Performance may be impacted with very large datasets due to multiple aggregations.
    
    */