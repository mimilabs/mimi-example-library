-- Title: MEPS Healthcare Service Proxy Reporting Analysis
-- Business Purpose:
-- Analyzes patterns of proxy-reported healthcare events to understand:
-- 1. Which types of medical services are most commonly reported by proxies vs self-reported
-- 2. How proxy reporting patterns have changed over time
-- 3. Implications for data accuracy and collection strategies

-- Main Query
WITH proxy_trends AS (
    SELECT 
        year,
        category,
        proxy,
        value_desc,
        COUNT(*) as report_count
    FROM mimi_ws_1.ahrq.meps_event_label_dictionary
    WHERE proxy IS NOT NULL 
    AND category IS NOT NULL
    GROUP BY year, category, proxy, value_desc
),

proxy_summary AS (
    SELECT 
        category,
        proxy,
        COUNT(DISTINCT year) as years_reported,
        SUM(report_count) as total_reports
    FROM proxy_trends
    GROUP BY category, proxy
)

SELECT 
    category,
    proxy,
    years_reported,
    total_reports,
    ROUND(total_reports * 100.0 / SUM(total_reports) OVER (PARTITION BY category), 2) as pct_within_category
FROM proxy_summary
WHERE total_reports > 0
ORDER BY category, total_reports DESC;

-- How the Query Works:
-- 1. First CTE (proxy_trends) aggregates reporting counts by year, category, and proxy status
-- 2. Second CTE (proxy_summary) calculates multi-year summaries for each category/proxy combination
-- 3. Final output shows the distribution of proxy vs self-reported events within each category

-- Assumptions and Limitations:
-- 1. Assumes proxy field is consistently coded across years
-- 2. Does not account for potential changes in proxy reporting policies over time
-- 3. May include some event types that are more likely to require proxy reporting by nature

-- Potential Extensions:
-- 1. Add trend analysis to show how proxy reporting has changed over specific time periods
-- 2. Include demographic breakdowns to identify which populations rely more on proxy reporting
-- 3. Compare proxy reporting patterns between different healthcare settings
-- 4. Analyze relationship between proxy reporting and specific medical conditions or procedures
-- 5. Cross-reference with data quality metrics to assess impact of proxy reporting on data accuracy

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:42:11.824293
    - Additional Notes: Query is particularly useful for data quality teams assessing reporting bias and researchers who need to account for proxy effects in their analysis. Considers only records where proxy status is explicitly defined, which may exclude some events.
    
    */