-- HEDIS High-Impact Measure Success Rate Analysis
-- Purpose: Identify Medicare Advantage plans with exceptional performance on 
-- critical HEDIS measures by calculating success rates and comparing them to 
-- expected benchmarks. This analysis helps:
-- - Highlight best-performing contracts for potential best practice sharing
-- - Quantify care delivery effectiveness across key measures
-- - Support strategic planning by identifying areas of excellence

WITH measure_rates AS (
    -- Calculate success rates and create performance metrics
    SELECT 
        contract_number,
        measure_name,
        hedis_year,
        observed_count,
        expected_count,
        denominator,
        -- Calculate success rate as observed vs denominator
        ROUND(CAST(observed_count AS FLOAT) / NULLIF(denominator, 0) * 100, 2) as success_rate,
        -- Calculate performance ratio compared to expected
        ROUND(CAST(observed_count AS FLOAT) / NULLIF(expected_count, 0), 2) as performance_ratio
    FROM mimi_ws_1.partcd.hedis_rau_measures
    WHERE denominator > 100  -- Filter for statistical significance
)

SELECT 
    measure_name,
    hedis_year,
    COUNT(DISTINCT contract_number) as number_of_contracts,
    ROUND(AVG(success_rate), 2) as avg_success_rate,
    ROUND(AVG(performance_ratio), 2) as avg_performance_ratio,
    -- Identify top performing contracts
    COUNT(CASE WHEN performance_ratio >= 1.1 THEN 1 END) as contracts_exceeding_expected,
    -- Calculate percentage of high performers
    ROUND(COUNT(CASE WHEN performance_ratio >= 1.1 THEN 1 END) * 100.0 / 
          COUNT(DISTINCT contract_number), 1) as pct_high_performers
FROM measure_rates
GROUP BY measure_name, hedis_year
HAVING COUNT(DISTINCT contract_number) >= 10  -- Ensure adequate sample size
ORDER BY hedis_year DESC, avg_success_rate DESC;

-- How it works:
-- 1. Creates a CTE to calculate key performance metrics for each contract
-- 2. Aggregates results by measure and year to show industry-wide patterns
-- 3. Identifies proportion of high-performing contracts (>10% above expected)
-- 4. Filters for statistical significance using minimum denominators

-- Assumptions and Limitations:
-- - Assumes denominator of 100+ represents statistically valid sample
-- - Does not account for measure-specific risk adjustment factors
-- - Performance ratio of 1.1+ assumed as threshold for high performance
-- - Requires at least 10 contracts per measure for meaningful comparison

-- Possible Extensions:
-- 1. Add year-over-year trend analysis for consistent high performers
-- 2. Include geographic analysis to identify regional centers of excellence
-- 3. Incorporate contract size/member count for weighted analysis
-- 4. Add measure category grouping for clinical domain analysis
-- 5. Calculate confidence intervals for more robust statistical comparison

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:24:40.400305
    - Additional Notes: Query focuses on success rates and performance ratios relative to expectations, with minimum thresholds for statistical validity (100+ denominator, 10+ contracts per measure). Best suited for identifying high-performing contracts and measure-level trends rather than detailed contract-specific analysis.
    
    */