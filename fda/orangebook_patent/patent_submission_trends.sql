-- analyzing_patent_submission_trends.sql
-- Purpose: Analyze trends in patent submissions over time to understand industry dynamics
-- Business value: Insights into pharmaceutical company patent strategy and market competition
-- Table: mimi_ws_1.fda.orangebook_patent

WITH patent_submissions AS (
    -- Get patent submission counts by month and application type
    SELECT 
        DATE_TRUNC('month', submission_date) as submission_month,
        appl_type,
        COUNT(DISTINCT patent_no) as patent_count,
        COUNT(DISTINCT appl_no) as application_count,
        -- Calculate flags for drug substance and product patents
        SUM(CASE WHEN drug_substance_flag = 'Y' THEN 1 ELSE 0 END) as substance_patents,
        SUM(CASE WHEN drug_product_flag = 'Y' THEN 1 ELSE 0 END) as product_patents
    FROM mimi_ws_1.fda.orangebook_patent
    WHERE submission_date IS NOT NULL 
    GROUP BY 1, 2
),
rolling_averages AS (
    -- Calculate 6-month rolling averages
    SELECT 
        submission_month,
        appl_type,
        patent_count,
        application_count,
        AVG(patent_count) OVER (
            PARTITION BY appl_type 
            ORDER BY submission_month 
            ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
        ) as rolling_avg_patents,
        substance_patents,
        product_patents
    FROM patent_submissions
)
SELECT 
    submission_month,
    appl_type,
    patent_count,
    application_count,
    ROUND(rolling_avg_patents, 2) as rolling_avg_patents,
    substance_patents,
    product_patents,
    -- Calculate ratio of substance to product patents
    ROUND(CAST(substance_patents AS FLOAT) / NULLIF(product_patents, 0), 2) as substance_to_product_ratio
FROM rolling_averages
WHERE submission_month >= '2018-01-01'
ORDER BY submission_month DESC, appl_type;

-- How this query works:
-- 1. First CTE aggregates patent submissions by month and application type
-- 2. Second CTE calculates 6-month rolling averages
-- 3. Final select formats and presents the trends with key metrics

-- Assumptions and limitations:
-- 1. Assumes submission_date is populated and accurate
-- 2. Limited to data from 2018 onwards for relevant trends
-- 3. Null handling for division operations
-- 4. Rolling average calculation requires 6 months of data

-- Possible extensions:
-- 1. Add year-over-year comparison
-- 2. Include patent expiration analysis
-- 3. Break down by specific drug categories using joins to other tables
-- 4. Add seasonal adjustment factors
-- 5. Include market size or revenue impact analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:27:31.749345
    - Additional Notes: Query focuses on monthly patent submission patterns and ratios between drug substance and product patents. Rolling averages help smooth out monthly fluctuations. Consider memory usage when analyzing long time periods due to window functions.
    
    */