
/*******************************************************************************
Title: HDL Cholesterol Level Distribution Analysis from NHANES Data
 
Business Purpose:
- Analyze the distribution of HDL cholesterol levels in the US population
- Support cardiovascular health risk assessment and population health monitoring
- Provide baseline statistics for public health policy and interventions

Author: [Your Name]
Created: [Date]
*******************************************************************************/

-- Calculate key distribution metrics for HDL cholesterol levels
WITH hdl_stats AS (
  SELECT 
    -- Basic statistical measures in mg/dL
    COUNT(*) as total_samples,
    ROUND(AVG(lbdhdd), 1) as avg_hdl,
    ROUND(PERCENTILE(lbdhdd, 0.5), 1) as median_hdl,
    ROUND(MIN(lbdhdd), 1) as min_hdl,
    ROUND(MAX(lbdhdd), 1) as max_hdl,
    
    -- Risk category counts based on clinical guidelines
    -- HDL < 40 mg/dL is considered low and a risk factor
    SUM(CASE WHEN lbdhdd < 40 THEN 1 ELSE 0 END) as low_hdl_count,
    -- HDL >= 60 mg/dL is considered protective
    SUM(CASE WHEN lbdhdd >= 60 THEN 1 ELSE 0 END) as protective_hdl_count
  FROM mimi_ws_1.cdc.nhanes_lab_cholesterol_hdl
  WHERE lbdhdd IS NOT NULL -- Exclude missing values
)

SELECT
  total_samples,
  avg_hdl as average_hdl_mgdl,
  median_hdl as median_hdl_mgdl,
  min_hdl as minimum_hdl_mgdl,
  max_hdl as maximum_hdl_mgdl,
  ROUND(100.0 * low_hdl_count / total_samples, 1) as pct_low_hdl,
  ROUND(100.0 * protective_hdl_count / total_samples, 1) as pct_protective_hdl
FROM hdl_stats;

/*******************************************************************************
How this query works:
1. Creates a CTE to calculate key statistics from the HDL cholesterol data
2. Segments the population into clinical risk categories
3. Calculates percentage distributions for risk assessment
4. Returns a single row with comprehensive HDL distribution metrics

Assumptions and Limitations:
- Assumes HDL values are accurately recorded in mg/dL
- Risk categories based on standard clinical guidelines
- Does not account for demographic factors or time trends
- Treats all samples equally without population weighting

Possible Extensions:
1. Add demographic breakdowns (requires joining with demographic tables):
   - Age groups
   - Gender
   - Race/ethnicity

2. Add temporal analysis:
   - Trend analysis using mimi_src_file_date
   - Year-over-year comparisons

3. Enhanced risk analysis:
   - Cross-tabulation with other cholesterol measures
   - Correlation with other cardiovascular risk factors
   - More detailed risk stratification
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:53:38.856088
    - Additional Notes: Query provides population-level HDL cholesterol statistics from NHANES data, including risk category distributions. Results are unweighted and should be interpreted within the context of NHANES sampling methodology. For clinical decision-making, individual patient context and additional risk factors should be considered.
    
    */