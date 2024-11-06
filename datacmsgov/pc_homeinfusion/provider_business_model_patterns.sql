-- Business Name Patterns Analysis for Home Infusion Therapy Market Segmentation
--
-- Business Purpose:
-- Analyzes naming patterns of home infusion therapy providers to understand:
-- 1. Market segmentation between independent vs chain providers
-- 2. Common business models and service focus areas
-- 3. Potential opportunities for partnership or acquisition targets
--
-- This analysis helps healthcare organizations and investors understand
-- market structure and competitive dynamics in the home infusion space.

WITH provider_name_patterns AS (
  -- Extract and categorize key terms from business names
  SELECT 
    DISTINCT legal_business_name,
    CASE 
      WHEN LOWER(legal_business_name) LIKE '%pharmacy%' THEN 'Pharmacy-Based'
      WHEN LOWER(legal_business_name) LIKE '%health%' OR LOWER(legal_business_name) LIKE '%healthcare%' THEN 'Healthcare Services'
      WHEN LOWER(legal_business_name) LIKE '%medical%' THEN 'Medical Services'
      WHEN LOWER(legal_business_name) LIKE '%hospital%' THEN 'Hospital-Affiliated'
      ELSE 'Other'
    END as business_type,
    state
  FROM mimi_ws_1.datacmsgov.pc_homeinfusion
  WHERE legal_business_name IS NOT NULL
),

business_model_summary AS (
  -- Aggregate counts by business type and state
  SELECT 
    business_type,
    state,
    COUNT(*) as provider_count
  FROM provider_name_patterns
  GROUP BY business_type, state
)

-- Generate final summary with rankings
SELECT 
  business_type,
  state,
  provider_count,
  RANK() OVER (PARTITION BY state ORDER BY provider_count DESC) as rank_in_state,
  ROUND(provider_count * 100.0 / SUM(provider_count) OVER (PARTITION BY state), 1) as pct_of_state
FROM business_model_summary
WHERE provider_count > 1
ORDER BY state, provider_count DESC;

-- How this query works:
-- 1. First CTE analyzes business names to categorize providers
-- 2. Second CTE aggregates counts by category and state
-- 3. Final query adds rankings and percentage calculations
--
-- Assumptions and Limitations:
-- - Categories are based on simple keyword matching in business names
-- - Some providers may be miscategorized due to naming conventions
-- - Analysis doesn't capture parent company relationships
-- - Historical trends not included due to single snapshot nature
--
-- Possible Extensions:
-- - Add time series analysis using mimi_src_file_date
-- - Include revenue or size indicators if available
-- - Cross-reference with acquisition/merger databases
-- - Add geographic clustering analysis
-- - Enhance categorization logic with machine learning

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:02:40.149312
    - Additional Notes: The query uses business name pattern matching to segment providers into categories, which may require periodic updates to the categorization logic as new naming patterns emerge. Consider enhancing the CASE statement with additional keywords for more precise categorization.
    
    */