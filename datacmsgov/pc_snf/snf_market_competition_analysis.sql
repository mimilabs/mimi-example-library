-- Title: SNF Market Coverage and Service Accessibility Analysis

-- Business Purpose:
-- This analysis evaluates the accessibility and market coverage of Skilled Nursing Facilities
-- by examining:
-- 1. The density of SNFs per zip code to identify potential service gaps
-- 2. Areas with single vs multiple facility coverage
-- 3. The relationship between facility types and market presence
-- This information helps identify underserved areas and opportunities for expansion.

WITH zip_level_metrics AS (
  -- Calculate facility counts and type distribution by zip code
  SELECT 
    zip_code,
    COUNT(DISTINCT enrollment_id) as facility_count,
    COUNT(DISTINCT provider_type_code) as service_type_count,
    COUNT(DISTINCT provider_type_text) as unique_service_types,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'P' THEN enrollment_id END) as profit_count,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'N' THEN enrollment_id END) as nonprofit_count
  FROM mimi_ws_1.datacmsgov.pc_snf
  WHERE zip_code IS NOT NULL
  GROUP BY zip_code
),

market_coverage AS (
  -- Categorize markets by coverage level
  SELECT
    CASE 
      WHEN facility_count = 1 THEN 'Single Provider'
      WHEN facility_count BETWEEN 2 AND 3 THEN 'Limited Competition'
      WHEN facility_count BETWEEN 4 AND 5 THEN 'Moderate Competition'
      ELSE 'High Competition'
    END as market_type,
    COUNT(*) as zip_count,
    AVG(service_type_count) as avg_service_types,
    AVG(profit_count * 1.0 / NULLIF(facility_count, 0)) as profit_facility_ratio
  FROM zip_level_metrics
  GROUP BY 
    CASE 
      WHEN facility_count = 1 THEN 'Single Provider'
      WHEN facility_count BETWEEN 2 AND 3 THEN 'Limited Competition'
      WHEN facility_count BETWEEN 4 AND 5 THEN 'Moderate Competition'
      ELSE 'High Competition'
    END
)

-- Final result combining market insights
SELECT 
  market_type,
  zip_count,
  ROUND(avg_service_types, 2) as avg_service_types,
  ROUND(profit_facility_ratio * 100, 1) as for_profit_percentage,
  ROUND(zip_count * 100.0 / SUM(zip_count) OVER (), 1) as market_share_percentage
FROM market_coverage
ORDER BY zip_count DESC;

-- How this query works:
-- 1. First CTE aggregates facility data at the zip code level
-- 2. Second CTE categorizes markets by competition level
-- 3. Final query summarizes market characteristics and calculates percentages

-- Assumptions and Limitations:
-- 1. Zip codes are used as proxy for local markets
-- 2. All facilities in database are currently active
-- 3. Service areas may cross zip code boundaries
-- 4. Does not account for facility size or capacity
-- 5. Market categorization thresholds are somewhat arbitrary

-- Possible Extensions:
-- 1. Add geographic clustering analysis
-- 2. Include facility size/capacity metrics
-- 3. Incorporate demographic data by zip code
-- 4. Add temporal analysis of market changes
-- 5. Include quality metrics in market assessment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:25:30.351141
    - Additional Notes: Query focuses on zip code level market competition metrics. For accurate results, ensure the table contains current facility data as historical/inactive facilities could skew the competition analysis. The profit ratio calculations assume valid proprietary_nonprofit flags ('P'/'N') in the source data.
    
    */