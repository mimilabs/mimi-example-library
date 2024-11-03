-- NADAC Over-the-Counter (OTC) Drug Price Analysis
--
-- Business Purpose:
-- This query analyzes OTC drug pricing patterns in NADAC data to:
-- 1. Assess pricing differences between prescription and OTC medications
-- 2. Identify cost-effective OTC alternatives for common conditions
-- 3. Support policy decisions around OTC drug coverage
-- 4. Guide patient education on prescription vs OTC options

WITH otc_summary AS (
  -- Get the most recent pricing data for each NDC
  SELECT
    ndc_description,
    otc,
    pricing_unit,
    nadac_per_unit,
    YEAR(effective_date) as price_year,
    classification_for_rate_setting
  FROM mimi_ws_1.datamedicaidgov.nadac
  WHERE effective_date >= '2020-01-01'  -- Focus on recent 3+ years
    AND nadac_per_unit > 0  -- Exclude zero prices
    AND explanation_code IN ('1','2','3')  -- Focus on survey-based prices
),

price_stats AS (
  -- Calculate summary statistics by OTC status
  SELECT 
    otc,
    pricing_unit,
    price_year,
    COUNT(DISTINCT ndc_description) as drug_count,
    ROUND(AVG(nadac_per_unit),4) as avg_price,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nadac_per_unit),4) as median_price
  FROM otc_summary
  GROUP BY otc, pricing_unit, price_year
)

-- Final output comparing OTC vs prescription pricing trends
SELECT
  price_year,
  otc,
  pricing_unit,
  drug_count,
  avg_price,
  median_price,
  ROUND(100.0 * (avg_price - LAG(avg_price) OVER 
    (PARTITION BY otc, pricing_unit ORDER BY price_year)), 2) as pct_price_change
FROM price_stats
ORDER BY pricing_unit, otc, price_year;

-- How this query works:
-- 1. Creates a base subset of recent NADAC data with valid prices
-- 2. Calculates key price metrics separately for OTC vs prescription drugs
-- 3. Computes year-over-year price changes to show trends
-- 4. Groups by pricing unit (ML, GM, EA) to enable proper comparisons

-- Assumptions & Limitations:
-- - Focuses only on survey-based prices (explanation codes 1-3)
-- - Excludes zero/null prices which may indicate data quality issues
-- - Does not account for package size differences
-- - Year-over-year changes may be affected by product mix changes

-- Possible Extensions:
-- 1. Add therapeutic category analysis for OTC vs Rx comparisons
-- 2. Include package size normalization
-- 3. Add seasonal pricing pattern analysis for OTC products
-- 4. Compare private label vs branded OTC pricing
-- 5. Link to specific conditions/symptoms where OTC alternatives exist

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:54:43.159647
    - Additional Notes: Query provides balanced price comparison between OTC and prescription drugs, focusing on the period after 2020 to ensure data recency. Consider adding a date parameter to make the analysis timeframe configurable if reusing for different time periods.
    
    */