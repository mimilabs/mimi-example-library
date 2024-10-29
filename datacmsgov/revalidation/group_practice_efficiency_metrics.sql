-- Group Practice Staffing and Efficiency Analysis
-- 
-- Business Purpose: 
-- Analyzes group practices' staffing levels and provider mix to identify high-performing
-- organizations and potential efficiency opportunities. This supports:
-- - Practice benchmarking and operational improvement initiatives
-- - M&A target identification and due diligence
-- - Value-based care network development
--

WITH practice_summary AS (
  -- Aggregate key metrics at the group practice level
  SELECT 
    group_legal_business_name,
    group_state_code,
    group_due_date,
    COUNT(DISTINCT individual_pac_id) as total_providers,
    COUNT(DISTINCT individual_specialty_description) as specialty_count,
    SUM(CASE WHEN record_type = 'Reassignment' THEN 1 ELSE 0 END) as reassigned_providers,
    AVG(individual_total_employer_associations) as avg_employer_associations
  FROM mimi_ws_1.datacmsgov.revalidation
  WHERE group_due_date != 'TBD'
  GROUP BY 1,2,3
),

practice_rankings AS (
  -- Calculate percentile rankings for key metrics
  SELECT 
    *,
    PERCENT_RANK() OVER (ORDER BY total_providers) as size_percentile,
    PERCENT_RANK() OVER (ORDER BY specialty_count) as specialty_mix_percentile,
    PERCENT_RANK() OVER (ORDER BY reassigned_providers) as reassignment_percentile
  FROM practice_summary
)

SELECT 
  group_legal_business_name,
  group_state_code,
  total_providers,
  specialty_count,
  reassigned_providers,
  ROUND(avg_employer_associations,2) as avg_employer_associations,
  ROUND(size_percentile * 100,1) as practice_size_percentile,
  ROUND(specialty_mix_percentile * 100,1) as specialty_mix_percentile,
  ROUND(reassignment_percentile * 100,1) as reassignment_percentile,
  group_due_date
FROM practice_rankings
WHERE total_providers >= 5  -- Focus on established practices
ORDER BY total_providers DESC
LIMIT 100;

-- How this query works:
-- 1. Creates practice_summary CTE to aggregate key metrics by practice
-- 2. Adds percentile rankings in practice_rankings CTE for comparative analysis
-- 3. Returns top 100 practices by size with key operational metrics and rankings

-- Assumptions & Limitations:
-- - Excludes practices with TBD revalidation dates
-- - Minimum threshold of 5 providers to filter out very small practices
-- - Rankings based on simple percentiles, could be enhanced with more sophisticated scoring
-- - Does not account for practice subspecialties or service mix

-- Possible Extensions:
-- 1. Add geographic analysis by aggregating at state/region level
-- 2. Include specialty-specific metrics and benchmarks
-- 3. Trend analysis by comparing across multiple mimi_src_file_dates
-- 4. Join to other CMS tables for quality metrics or payment data
-- 5. Add filters for specific specialties or practice types of interest

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:25:47.904155
    - Additional Notes: The query focuses on operational efficiency metrics for larger group practices and enables comparative analysis through percentile rankings. Note that practices with fewer than 5 providers are excluded, and the analysis is limited to practices with defined revalidation dates. The results are most useful for benchmarking established medical groups and identifying high-performing organizations based on size, specialty mix, and provider retention metrics.
    
    */