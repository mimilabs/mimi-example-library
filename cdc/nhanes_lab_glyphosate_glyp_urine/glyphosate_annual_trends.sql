/* NHANES Glyphosate Temporal Exposure Trends Analysis
   
Business Purpose:
This query analyzes how glyphosate exposure levels have changed over time in the U.S. population
by examining measurements across different NHANES survey cycles. Understanding temporal trends
is crucial for:
- Evaluating the effectiveness of regulatory policies
- Assessing population-level exposure changes
- Informing public health intervention strategies
*/

SELECT 
    -- Extract year from source file name for temporal analysis
    SUBSTRING(mimi_src_file_name, 7, 4) as survey_year,
    
    -- Calculate key statistics for each year
    COUNT(seqn) as total_samples,
    ROUND(AVG(CASE WHEN ssglyp > 0 THEN ssglyp END), 2) as avg_glyphosate_level,
    ROUND(PERCENTILE(CASE WHEN ssglyp > 0 THEN ssglyp END, 0.5), 2) as median_glyphosate_level,
    ROUND(PERCENTILE(CASE WHEN ssglyp > 0 THEN ssglyp END, 0.75), 2) as p75_glyphosate_level,
    
    -- Calculate detection rate
    ROUND(100.0 * COUNT(CASE WHEN ssglyp > 0 THEN 1 END) / COUNT(*), 1) as detection_rate_percent

FROM mimi_ws_1.cdc.nhanes_lab_glyphosate_glyp_urine

GROUP BY SUBSTRING(mimi_src_file_name, 7, 4)
ORDER BY survey_year;

/* How this query works:
- Extracts survey year from the source file name
- Calculates average and percentile statistics for detected glyphosate levels
- Computes detection rate as percentage of samples above detection limit
- Groups results by survey year to show temporal trends

Assumptions and Limitations:
- Assumes source file naming convention includes year consistently
- Only considers positive glyphosate values for statistics
- Does not account for changes in sampling methodology between cycles
- Does not weight results using survey weights

Possible Extensions:
1. Add confidence intervals around the mean values
2. Include year-over-year percent changes
3. Break down trends by demographic subgroups
4. Incorporate survey weights for population-representative estimates
5. Add statistical tests for trend significance
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:32:17.515193
    - Additional Notes: Query focuses on year-over-year trends in glyphosate exposure levels and detection rates. Note that results do not incorporate NHANES survey weights, which would be needed for true population-representative estimates. The year extraction method assumes consistent file naming conventions in mimi_src_file_name field.
    
    */