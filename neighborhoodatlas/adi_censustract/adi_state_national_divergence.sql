-- adi_socioeconomic_outliers.sql

-- Business Purpose:
-- Identify census tracts where national and state ADI rankings significantly diverge
-- to surface areas that may require special attention in healthcare program design.
-- These "outlier" areas often represent unique socioeconomic contexts that need
-- customized approaches for healthcare delivery and community outreach.

WITH ranked_differences AS (
  -- Calculate the absolute difference between national and state rankings
  -- and identify statistical outliers
  SELECT 
    fips_censustract,
    adi_natrank_avg,
    adi_staternk_avg,
    ABS(adi_natrank_avg - adi_staternk_avg) as rank_difference,
    -- Extract state FIPS code (first 2 digits)
    LEFT(fips_censustract, 2) as state_fips
  FROM mimi_ws_1.neighborhoodatlas.adi_censustract
  WHERE adi_natrank_avg IS NOT NULL 
    AND adi_staternk_avg IS NOT NULL
),

state_metrics AS (
  -- Calculate state-level statistics for contextual comparison
  SELECT
    state_fips,
    AVG(rank_difference) as avg_difference,
    STDDEV(rank_difference) as std_difference,
    COUNT(*) as tract_count
  FROM ranked_differences
  GROUP BY state_fips
)

SELECT 
  r.fips_censustract,
  r.state_fips,
  r.adi_natrank_avg as national_rank,
  r.adi_staternk_avg as state_rank,
  r.rank_difference,
  s.avg_difference as state_avg_difference,
  s.tract_count,
  -- Flag tracts where ranking difference is notably high
  CASE 
    WHEN r.rank_difference > (s.avg_difference + 2*s.std_difference) THEN 'High Divergence'
    WHEN r.rank_difference < (s.avg_difference - 2*s.std_difference) THEN 'Low Divergence'
    ELSE 'Normal'
  END as divergence_category
FROM ranked_differences r
JOIN state_metrics s ON r.state_fips = s.state_fips
WHERE s.tract_count >= 100  -- Ensure sufficient sample size
ORDER BY r.rank_difference DESC
LIMIT 1000;

-- How it works:
-- 1. Calculates absolute differences between national and state ADI rankings
-- 2. Computes state-level statistical measures
-- 3. Identifies census tracts with significant divergence from state patterns
-- 4. Categories tracts based on statistical thresholds (2 standard deviations)

-- Assumptions and Limitations:
-- - Requires both national and state rankings to be non-null
-- - Uses 2 standard deviations as threshold for outlier detection
-- - Limited to states with at least 100 census tracts for statistical validity
-- - Current implementation focuses on most recent data only

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in divergence patterns
-- 2. Include demographic or healthcare utilization data for deeper insights
-- 3. Create geographic clusters of high-divergence areas
-- 4. Add specific state-level benchmarks for targeted analysis
-- 5. Incorporate additional socioeconomic indicators for validation

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:25:39.347922
    - Additional Notes: Query focuses on identifying geographic areas where state and national ADI rankings show significant statistical divergence, useful for healthcare policy planning and resource allocation. Note that results are limited to states with 100+ census tracts and requires recent, complete ADI data.
    
    */