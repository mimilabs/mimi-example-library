-- hedis_measure_compliance_gaps.sql

-- Purpose: Identify significant gaps in HEDIS measure compliance rates across contracts
-- to prioritize targeted quality improvement initiatives
--
-- Business Value:
-- - Highlights measures with the largest compliance gaps needing attention
-- - Enables data-driven decisions for quality improvement resource allocation
-- - Supports contract performance benchmarking and goal-setting
-- - Helps identify potential best practices from high-performing contracts

WITH measure_stats AS (
  -- Calculate key statistics for each measure
  SELECT
    measure_code,
    measure_name,
    hedis_year,
    AVG(rate) as avg_rate,
    PERCENTILE(rate, 0.75) as top_quartile_rate,
    PERCENTILE(rate, 0.25) as bottom_quartile_rate,
    COUNT(DISTINCT contract_number) as contract_count
  FROM mimi_ws_1.partcd.hedis_measures
  WHERE rate IS NOT NULL 
    AND rate > 0 
    AND rate <= 100
  GROUP BY measure_code, measure_name, hedis_year
),

compliance_gaps AS (
  -- Calculate compliance gaps and rank measures
  SELECT 
    measure_code,
    measure_name,
    hedis_year,
    avg_rate,
    top_quartile_rate,
    bottom_quartile_rate,
    (top_quartile_rate - bottom_quartile_rate) as quartile_gap,
    contract_count,
    RANK() OVER (PARTITION BY hedis_year ORDER BY (top_quartile_rate - bottom_quartile_rate) DESC) as gap_rank
  FROM measure_stats
  WHERE contract_count >= 10 -- Ensure sufficient sample size
)

-- Output final results focusing on measures with largest gaps
SELECT 
  measure_code,
  measure_name,
  hedis_year,
  ROUND(avg_rate, 1) as avg_rate_pct,
  ROUND(top_quartile_rate, 1) as top_quartile_pct,
  ROUND(bottom_quartile_rate, 1) as bottom_quartile_pct,
  ROUND(quartile_gap, 1) as performance_gap_pct,
  contract_count,
  gap_rank
FROM compliance_gaps
WHERE gap_rank <= 10 -- Focus on top 10 measures with largest gaps
ORDER BY hedis_year DESC, gap_rank;

-- How it works:
-- 1. First CTE calculates key statistics for each measure including quartile rates
-- 2. Second CTE identifies compliance gaps and ranks measures
-- 3. Final query returns top measures with largest performance gaps
--
-- Assumptions and limitations:
-- - Requires at least 10 contracts per measure for meaningful comparison
-- - Assumes rates are on 0-100 scale
-- - Does not account for measure-specific clinical complexity
-- - Gap analysis based on inter-quartile range may not capture all meaningful variations
--
-- Possible extensions:
-- 1. Add year-over-year gap trend analysis
-- 2. Include contract size/volume weighting
-- 3. Add geographic stratification
-- 4. Incorporate specific measure targets or benchmarks
-- 5. Add drill-down to contract-level detail for specific measures

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:33:40.052281
    - Additional Notes: Query identifies largest performance gaps across HEDIS measures by comparing top and bottom quartile rates. Minimum threshold of 10 contracts per measure ensures statistical relevance. Results limited to top 10 measures with largest gaps per year to focus on highest-impact improvement opportunities.
    
    */