-- nhanes_liver_screening.sql
-- 
-- Business Purpose:
-- - Identify potential liver health concerns in the population by analyzing key liver enzymes  
-- - Support population health screening and early intervention strategies
-- - Enable evidence-based liver disease prevention programs
--
-- The query analyzes the distribution of key liver enzymes (ALT, AST, ALP) 
-- and identifies cases that may indicate potential liver issues based on established
-- clinical thresholds.

WITH liver_metrics AS (
  SELECT 
    -- Core identifiers and measurements
    seqn,
    lbxsatsi as alt_level,
    lbxsassi as ast_level, 
    lbxsapsi as alp_level,
    lbxstb as total_bilirubin,
    
    -- Categorize liver enzyme levels based on clinical thresholds
    CASE 
      WHEN lbxsatsi > 40 THEN 'Elevated'
      WHEN lbxsatsi <= 40 THEN 'Normal'
      ELSE 'Unknown'
    END as alt_status,
    
    CASE
      WHEN lbxsassi > 40 THEN 'Elevated' 
      WHEN lbxsassi <= 40 THEN 'Normal'
      ELSE 'Unknown'
    END as ast_status,
    
    -- Extract year from source file for trending
    YEAR(mimi_src_file_date) as measurement_year
    
  FROM mimi_ws_1.cdc.nhanes_lab_standard_biochemistry_profile
  WHERE lbxsatsi IS NOT NULL 
    AND lbxsassi IS NOT NULL
)

SELECT
  measurement_year,
  COUNT(*) as total_cases,
  
  -- Calculate prevalence of elevated enzymes
  ROUND(100.0 * SUM(CASE WHEN alt_status = 'Elevated' THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_elevated_alt,
  ROUND(100.0 * SUM(CASE WHEN ast_status = 'Elevated' THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_elevated_ast,
  
  -- Get enzyme level distributions
  ROUND(AVG(alt_level), 1) as avg_alt,
  ROUND(AVG(ast_level), 1) as avg_ast,
  ROUND(AVG(alp_level), 1) as avg_alp,
  
  -- Identify concerning cases
  SUM(CASE WHEN alt_status = 'Elevated' AND ast_status = 'Elevated' THEN 1 ELSE 0 END) as both_elevated_count

FROM liver_metrics
GROUP BY measurement_year
ORDER BY measurement_year;

-- How it works:
-- 1. Creates a CTE to transform raw enzyme measurements into clinical categories
-- 2. Calculates yearly prevalence of elevated liver enzymes
-- 3. Provides distribution statistics of key liver markers
-- 4. Identifies cases with multiple elevated enzymes for potential follow-up

-- Assumptions & Limitations:
-- - Uses standard clinical thresholds for liver enzymes (may need adjustment)
-- - Requires non-null ALT and AST values
-- - Does not account for demographic factors or other clinical conditions
-- - Point-in-time measurements may not reflect long-term liver health

-- Possible Extensions:
-- 1. Add demographic stratification (age, gender, ethnicity)
-- 2. Include additional liver function markers (GGT, albumin)
-- 3. Create risk scoring based on multiple marker patterns
-- 4. Add trending analysis across multiple NHANES cycles
-- 5. Compare against known liver disease prevalence rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:51:39.167252
    - Additional Notes: Query focuses on population-level liver enzyme screening using ALT/AST ratios and clinical thresholds. Results are aggregated annually which may mask seasonal variations. Consider local lab reference ranges when interpreting results as thresholds are standardized at 40 U/L.
    
    */