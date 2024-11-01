-- Institute Topic Coverage Trend Analysis
-- Business Purpose: Analyze how medical institute coverage of health topics 
-- has evolved over time to identify emerging focus areas and potential gaps
-- in medical knowledge distribution.

WITH institute_topic_dates AS (
    -- Get the first and last appearance dates for each institute-topic pair
    SELECT 
        institute,
        COUNT(DISTINCT topic_id) as topic_count,
        MIN(mimi_src_file_date) as first_coverage_date,
        MAX(mimi_src_file_date) as last_coverage_date,
        DATEDIFF(MAX(mimi_src_file_date), MIN(mimi_src_file_date)) as coverage_duration_days
    FROM mimi_ws_1.medlineplus.primary_institute
    GROUP BY institute
),
metrics AS (
    -- Calculate coverage metrics and changes
    SELECT 
        institute,
        topic_count,
        first_coverage_date,
        last_coverage_date,
        coverage_duration_days,
        ROUND(topic_count / NULLIF(coverage_duration_days, 0) * 365, 2) as topics_per_year
    FROM institute_topic_dates
    WHERE coverage_duration_days > 0
)

SELECT 
    institute,
    topic_count,
    first_coverage_date,
    last_coverage_date,
    coverage_duration_days,
    topics_per_year
FROM metrics
WHERE topic_count >= 5  -- Focus on institutes with meaningful coverage
ORDER BY topics_per_year DESC, topic_count DESC
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates topic coverage dates by institute
-- 2. Second CTE calculates key metrics including topics per year
-- 3. Final query filters and sorts results to show most active institutes

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date reflects actual content updates
-- - Only considers institutes with 5+ topics for significance
-- - Does not account for potential gaps in coverage periods
-- - Linear growth assumption for topics_per_year calculation

-- Possible Extensions:
-- 1. Add topic category analysis to show institute specialization
-- 2. Compare institute coverage patterns across different time periods
-- 3. Identify institutes with declining vs growing topic coverage
-- 4. Add geographical analysis based on institute locations
-- 5. Create institute collaboration network analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:19:02.050517
    - Additional Notes: Query focuses on temporal patterns of institute topic coverage. Consider adjusting the topic_count threshold (currently 5) based on specific analysis needs. The topics_per_year metric assumes linear growth and may not reflect seasonal or irregular update patterns.
    
    */