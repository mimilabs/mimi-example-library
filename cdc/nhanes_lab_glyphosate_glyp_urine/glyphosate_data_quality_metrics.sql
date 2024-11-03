/* Glyphosate Sample Quality Control Analysis
   
Business Purpose: 
This query assesses the quality and completeness of glyphosate measurements across NHANES survey cycles 
to validate data reliability and identify potential measurement issues. Understanding data quality is 
critical for researchers and policy makers relying on this data for exposure assessments and 
public health decisions.
*/

WITH sample_metrics AS (
    -- Calculate key quality metrics by source file
    SELECT 
        mimi_src_file_name,
        COUNT(*) as total_samples,
        COUNT(CASE WHEN ssglyp IS NOT NULL THEN 1 END) as measured_samples,
        COUNT(CASE WHEN ssglypl IS NOT NULL THEN 1 END) as comment_coded_samples,
        MIN(ssglyp) as min_concentration,
        MAX(ssglyp) as max_concentration,
        AVG(ssglyp) as avg_concentration
    FROM mimi_ws_1.cdc.nhanes_lab_glyphosate_glyp_urine
    GROUP BY mimi_src_file_name
),
completeness_check AS (
    -- Assess weight variable completeness by survey cycle
    SELECT 
        mimi_src_file_name,
        COUNT(CASE WHEN wtssbj2y IS NOT NULL THEN 1 END) as j_weights_count,
        COUNT(CASE WHEN wtssgl2y IS NOT NULL THEN 1 END) as i_weights_count,
        COUNT(CASE WHEN wtssch2y IS NOT NULL THEN 1 END) as h_weights_count
    FROM mimi_ws_1.cdc.nhanes_lab_glyphosate_glyp_urine
    GROUP BY mimi_src_file_name
)

SELECT 
    sm.mimi_src_file_name,
    sm.total_samples,
    sm.measured_samples,
    ROUND(100.0 * sm.measured_samples / sm.total_samples, 2) as measurement_rate,
    sm.comment_coded_samples,
    ROUND(sm.min_concentration, 4) as min_conc_ng_ml,
    ROUND(sm.max_concentration, 4) as max_conc_ng_ml,
    ROUND(sm.avg_concentration, 4) as avg_conc_ng_ml,
    cc.j_weights_count,
    cc.i_weights_count, 
    cc.h_weights_count
FROM sample_metrics sm
JOIN completeness_check cc ON sm.mimi_src_file_name = cc.mimi_src_file_name
ORDER BY sm.mimi_src_file_name;

/* How this query works:
1. First CTE (sample_metrics) calculates basic measurement statistics by source file
2. Second CTE (completeness_check) evaluates the presence of survey weights
3. Final SELECT joins these metrics and formats for reporting

Assumptions and Limitations:
- Assumes each source file represents a distinct survey cycle
- Does not account for detection limits or specific comment codes
- Weight variables are cycle-specific and should only be present for their respective cycles

Possible Extensions:
1. Add detailed analysis of comment codes (ssglypl) to understand measurement quality issues
2. Include temporal analysis by incorporating mimi_src_file_date
3. Add statistical tests for significant differences between cycles
4. Compare measurement rates against other NHANES biomarker measurements
5. Analyze demographic coverage using weight variables
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:53:03.923249
    - Additional Notes: Query provides a comprehensive data quality assessment tool for NHANES glyphosate measurements, particularly useful for researchers validating dataset completeness and reliability before conducting exposure analyses. The script helps identify potential measurement gaps and inconsistencies across survey cycles.
    
    */