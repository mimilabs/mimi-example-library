-- health_topic_language_seasonality_analysis.sql

-- Business Purpose: 
-- This analysis explores seasonal patterns in health topic creation across different languages
-- to help content strategists optimize the timing and prioritization of new health content.
-- Understanding these patterns can improve content planning and resource allocation for
-- multilingual health education initiatives.

WITH monthly_topics AS (
    -- Aggregate health topics by month and language
    SELECT 
        DATE_TRUNC('month', date_created) as creation_month,
        language,
        COUNT(*) as topics_created,
        -- Calculate running total of topics per language
        SUM(COUNT(*)) OVER (PARTITION BY language ORDER BY DATE_TRUNC('month', date_created)) as cumulative_topics
    FROM mimi_ws_1.medlineplus.health_topic
    WHERE date_created IS NOT NULL
        AND language IS NOT NULL
    GROUP BY DATE_TRUNC('month', date_created), language
),

seasonal_patterns AS (
    -- Analyze seasonal trends by extracting month from dates
    SELECT 
        MONTH(creation_month) as month_num,
        language,
        AVG(topics_created) as avg_topics_per_month,
        MAX(cumulative_topics) as total_topics_to_date
    FROM monthly_topics
    GROUP BY MONTH(creation_month), language
)

-- Final output combining key metrics
SELECT 
    month_num,
    language,
    ROUND(avg_topics_per_month, 2) as avg_monthly_topics,
    total_topics_to_date,
    -- Calculate percentage of total content by language
    ROUND(100.0 * total_topics_to_date / SUM(total_topics_to_date) OVER (PARTITION BY language), 2) as pct_of_language_total
FROM seasonal_patterns
ORDER BY language, month_num;

-- How the Query Works:
-- 1. Creates monthly aggregates of health topics by language
-- 2. Calculates running totals to show content growth
-- 3. Analyzes seasonal patterns by extracting month numbers
-- 4. Combines metrics to show monthly averages and totals

-- Assumptions and Limitations:
-- - Assumes date_created is consistently populated and accurate
-- - Does not account for topic updates or removals
-- - Seasonal patterns may vary by year and region
-- - Limited to available languages in the dataset

-- Possible Extensions:
-- 1. Add year-over-year comparison of seasonal patterns
-- 2. Include topic categories to identify subject-specific seasonality
-- 3. Correlate with external factors (e.g., disease outbreaks, health awareness months)
-- 4. Add topic complexity metrics to analyze content depth trends
-- 5. Compare seasonal patterns between different regions or target audiences

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:28:02.483238
    - Additional Notes: The query focuses on comparing content creation patterns across languages. Performance may be impacted with large date ranges due to the window functions and multiple aggregations. Consider adding date range filters for production use.
    
    */