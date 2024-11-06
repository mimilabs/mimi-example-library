-- Title: ADI Disparity Analysis for High-Risk Counties
-- Author: Healthcare Analytics Team
-- Date: 2024-02-15
--
-- Business Purpose:
-- Identify counties with significant internal socioeconomic disparities by analyzing
-- ADI standard deviation patterns. This helps healthcare organizations target
-- resources to areas with the most heterogeneous needs and potentially hidden
-- pockets of vulnerability.

WITH ranked_counties AS (
  -- Calculate disparity metrics and rank counties
  SELECT 
    fips_county,
    adi_natrank_avg,
    adi_natrank_std,
    -- Create disparity score combining both average ADI and its variation
    (adi_natrank_avg * adi_natrank_std) / 100 as disparity_score,
    -- Get the latest data only
    ROW_NUMBER() OVER (PARTITION BY fips_county ORDER BY mimi_src_file_date DESC) as rn
  FROM mimi_ws_1.neighborhoodatlas.adi_county
  WHERE adi_natrank_std IS NOT NULL 
    AND adi_natrank_avg IS NOT NULL
),

high_risk_counties AS (
  -- Focus on counties with significant internal variation
  SELECT 
    fips_county,
    adi_natrank_avg,
    adi_natrank_std,
    disparity_score,
    -- Categorize risk levels
    CASE 
      WHEN disparity_score >= 30 THEN 'Critical'
      WHEN disparity_score >= 20 THEN 'High'
      WHEN disparity_score >= 10 THEN 'Moderate'
      ELSE 'Low'
    END as risk_level
  FROM ranked_counties
  WHERE rn = 1  -- Latest data only
)

-- Final output with risk analysis
SELECT 
  risk_level,
  COUNT(*) as county_count,
  ROUND(AVG(adi_natrank_avg), 2) as avg_adi,
  ROUND(AVG(adi_natrank_std), 2) as avg_std,
  ROUND(AVG(disparity_score), 2) as avg_disparity_score
FROM high_risk_counties
GROUP BY risk_level
ORDER BY avg_disparity_score DESC;

-- How it works:
-- 1. Creates ranked_counties CTE to calculate a disparity score for each county
-- 2. Creates high_risk_counties CTE to categorize counties by risk level
-- 3. Produces summary statistics by risk category
--
-- Assumptions and Limitations:
-- - Assumes latest data is most relevant (filters by latest mimi_src_file_date)
-- - Disparity score calculation is a simplified model
-- - Does not account for geographic clustering of high-risk counties
-- - May need adjustment of risk level thresholds based on specific use cases
--
-- Possible Extensions:
-- 1. Add geographic grouping to identify regional patterns
-- 2. Include year-over-year trend analysis
-- 3. Incorporate population data to weight the analysis
-- 4. Add correlation analysis with specific health outcomes
-- 5. Create drill-down capability to identify specific block groups driving variation

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:12:53.052232
    - Additional Notes: The query builds a risk assessment framework using ADI standard deviation as a key metric for identifying hidden disparities within counties. The disparity_score calculation (ADI average * standard deviation / 100) is a simplified metric that may need calibration based on specific organizational needs. Risk level thresholds (30/20/10) should be validated against local demographic patterns before operational use.
    
    */