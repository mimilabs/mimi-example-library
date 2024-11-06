-- language_availability_trends.sql
-- Purpose: Analyzes trends in language availability over time for MedlinePlus topics
-- Business Value: Helps identify gaps in multilingual health content and track translation progress
-- to support healthcare accessibility and health literacy initiatives across diverse populations.

WITH language_extracts AS (
    -- Extract language from URL and count topics per language and date
    SELECT 
        REGEXP_EXTRACT(url, '/([a-z]{2,})/article/') as language_code,
        DATE_TRUNC('month', mimi_src_file_date) as month_date,
        COUNT(DISTINCT topic_id) as topic_count,
        COUNT(DISTINCT vernacular_name) as unique_translations
    FROM mimi_ws_1.medlineplus.other_language
    WHERE url IS NOT NULL
    GROUP BY 1, 2
),

month_over_month AS (
    -- Calculate month-over-month changes in translation coverage
    SELECT 
        language_code,
        month_date,
        topic_count,
        unique_translations,
        LAG(topic_count) OVER (PARTITION BY language_code ORDER BY month_date) as prev_month_count,
        LAG(unique_translations) OVER (PARTITION BY language_code ORDER BY month_date) as prev_month_translations
    FROM language_extracts
)

SELECT 
    language_code,
    month_date,
    topic_count,
    unique_translations,
    -- Calculate growth metrics
    ROUND(((topic_count - prev_month_count) / NULLIF(prev_month_count, 0)) * 100, 2) as topic_growth_pct,
    ROUND(((unique_translations - prev_month_translations) / NULLIF(prev_month_translations, 0)) * 100, 2) as translation_growth_pct
FROM month_over_month
WHERE month_date >= DATE_ADD(months, -12, CURRENT_DATE())
ORDER BY month_date DESC, topic_count DESC;

-- How it works:
-- 1. First CTE extracts language codes from URLs and aggregates topic counts by language and month
-- 2. Second CTE calculates previous month metrics using window functions
-- 3. Final query computes growth percentages and filters to last 12 months

-- Assumptions and Limitations:
-- - Assumes consistent URL structure with language codes
-- - Limited to languages with content in MedlinePlus
-- - Growth calculations may show null for first month of each language
-- - Does not account for content quality or completeness

-- Possible Extensions:
-- 1. Add seasonality analysis for translation patterns
-- 2. Compare translation coverage against population demographics
-- 3. Include topic categories to identify under-served medical subjects
-- 4. Create alerts for significant drops in translation coverage
-- 5. Build forecasting model for translation needs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:08:36.890934
    - Additional Notes: This query provides month-over-month growth tracking of multilingual health content. Consider adding error handling for malformed URLs and validate language codes against a reference table for more accurate reporting. Performance may be impacted with large date ranges due to window functions.
    
    */