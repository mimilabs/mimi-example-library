-- Title: Census Tract Population Exposure to High Social Deprivation Analysis

-- Business Purpose:
-- Identifies the total population living in highly deprived areas based on SDI scores,
-- helping healthcare organizations and policymakers understand the scale of populations
-- potentially at risk for poor health outcomes. This analysis supports resource allocation
-- and intervention planning by quantifying the population burden of social deprivation.

-- Main Query
WITH ranked_tracts AS (
  SELECT 
    censustract_fips,
    census_tract_population,
    sdi_score,
    -- Categorize SDI scores into quintiles for easier interpretation
    NTILE(5) OVER (ORDER BY sdi_score) as sdi_quintile
  FROM mimi_ws_1.grahamcenter.sdi_censustract
  WHERE mimi_src_file_date = '2019-12-31' -- Using most recent 5-year ACS data
  AND census_tract_population > 0 -- Exclude unpopulated tracts
),

population_by_severity AS (
  SELECT
    CASE 
      WHEN sdi_quintile = 5 THEN 'Highest Deprivation (Top 20%)'
      WHEN sdi_quintile = 4 THEN 'High Deprivation (60-80%)'
      ELSE 'Lower Deprivation (Bottom 60%)'
    END as deprivation_category,
    COUNT(*) as tract_count,
    SUM(census_tract_population) as total_population,
    AVG(sdi_score) as avg_sdi_score
  FROM ranked_tracts
  GROUP BY 
    CASE 
      WHEN sdi_quintile = 5 THEN 'Highest Deprivation (Top 20%)'
      WHEN sdi_quintile = 4 THEN 'High Deprivation (60-80%)'
      ELSE 'Lower Deprivation (Bottom 60%)'
    END
)

SELECT 
  deprivation_category,
  tract_count,
  total_population,
  ROUND(total_population * 100.0 / SUM(total_population) OVER (), 1) as pct_total_population,
  ROUND(avg_sdi_score, 2) as avg_sdi_score
FROM population_by_severity
ORDER BY avg_sdi_score DESC;

-- How the Query Works:
-- 1. Creates a CTE that assigns quintile rankings to census tracts based on SDI scores
-- 2. Groups tracts into three categories: Highest (top 20%), High (60-80%), and Lower (bottom 60%)
-- 3. Calculates population totals and averages for each category
-- 4. Presents results showing population exposure to different levels of deprivation

-- Assumptions and Limitations:
-- - Uses 2019 data (most recent 5-year ACS estimates)
-- - Assumes census tract population counts are accurate and current
-- - Does not account for population mobility between tracts
-- - Quintile-based categorization may not reflect absolute deprivation levels

-- Possible Extensions:
-- 1. Add geographic grouping (state/county level aggregation)
-- 2. Include year-over-year trend analysis
-- 3. Incorporate specific component scores (poverty, education, etc.)
-- 4. Add demographic breakdowns if available through joins
-- 5. Create risk-weighted population metrics based on SDI severity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:07:13.305392
    - Additional Notes: The query categorizes population exposure to social deprivation using quintiles, which allows for relative comparisons but may need adjustment based on absolute SDI thresholds for specific policy or research needs. Consider local demographic context when interpreting results, as the same SDI score may have different implications in different regions.
    
    */