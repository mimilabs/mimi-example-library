-- hs_crp_distribution_trends.sql
-- Business Purpose: 
-- Analyze the statistical distribution and longitudinal trends of hs-CRP values
-- in the NHANES population to support clinical guideline development and
-- population health monitoring. This baseline analysis helps healthcare organizations
-- establish reference ranges and identify shifts in inflammatory biomarker patterns.

WITH yearly_stats AS (
    -- Extract year from file name and calculate basic statistics
    SELECT 
        SUBSTRING(mimi_src_file_name, 7, 4) AS survey_year,
        COUNT(*) as sample_size,
        ROUND(AVG(lbxhscrp), 2) as mean_hscrp,
        ROUND(PERCENTILE(lbxhscrp, 0.5), 2) as median_hscrp,
        ROUND(PERCENTILE(lbxhscrp, 0.25), 2) as q1_hscrp,
        ROUND(PERCENTILE(lbxhscrp, 0.75), 2) as q3_hscrp
    FROM mimi_ws_1.cdc.nhanes_lab_highsensitivity_creactive_protein
    WHERE lbxhscrp IS NOT NULL
    GROUP BY SUBSTRING(mimi_src_file_name, 7, 4)
),

risk_distribution AS (
    -- Categorize hs-CRP values by clinical risk levels
    SELECT 
        SUBSTRING(mimi_src_file_name, 7, 4) AS survey_year,
        COUNT(*) as total_measurements,
        SUM(CASE WHEN lbxhscrp < 1 THEN 1 ELSE 0 END) as low_risk_count,
        SUM(CASE WHEN lbxhscrp >= 1 AND lbxhscrp <= 3 THEN 1 ELSE 0 END) as moderate_risk_count,
        SUM(CASE WHEN lbxhscrp > 3 THEN 1 ELSE 0 END) as high_risk_count
    FROM mimi_ws_1.cdc.nhanes_lab_highsensitivity_creactive_protein
    WHERE lbxhscrp IS NOT NULL
    GROUP BY SUBSTRING(mimi_src_file_name, 7, 4)
)

SELECT 
    y.survey_year,
    y.sample_size,
    y.mean_hscrp,
    y.median_hscrp,
    y.q1_hscrp,
    y.q3_hscrp,
    ROUND(100.0 * r.low_risk_count / r.total_measurements, 1) as pct_low_risk,
    ROUND(100.0 * r.moderate_risk_count / r.total_measurements, 1) as pct_moderate_risk,
    ROUND(100.0 * r.high_risk_count / r.total_measurements, 1) as pct_high_risk
FROM yearly_stats y
JOIN risk_distribution r ON y.survey_year = r.survey_year
ORDER BY y.survey_year;

-- How it works:
-- 1. First CTE extracts survey year and calculates basic descriptive statistics
-- 2. Second CTE categorizes hs-CRP values into clinical risk groups
-- 3. Final query joins both CTEs and calculates percentages for risk distribution
-- 4. Results are ordered chronologically by survey year

-- Assumptions and Limitations:
-- 1. Assumes the file naming convention includes the survey year in a consistent position
-- 2. Risk categories are based on standard clinical cutoffs (< 1, 1-3, > 3 mg/L)
-- 3. Null values are excluded from analysis
-- 4. Does not account for potential sampling weights in NHANES

-- Possible Extensions:
-- 1. Add seasonal analysis by extracting month from source dates
-- 2. Include demographic stratification if joined with other NHANES tables
-- 3. Add statistical tests for trend analysis across years
-- 4. Incorporate age-specific reference ranges
-- 5. Add outlier detection and handling logic

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:19:53.514866
    - Additional Notes: Query focuses on year-over-year distribution of hs-CRP risk levels and statistical measures. The risk categorization uses standard clinical thresholds (<1, 1-3, >3 mg/L). Results depend on consistent file naming patterns in mimi_src_file_name for year extraction.
    
    */