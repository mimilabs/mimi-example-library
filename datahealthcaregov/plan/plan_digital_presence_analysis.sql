-- Healthcare.gov Plan Marketing Effectiveness Analysis
-- ==========================================================
-- Business Purpose: Analyze the marketing approach and digital presence of healthcare plans
-- to understand how insurers communicate with potential customers and identify gaps
-- in digital engagement strategies.

WITH marketing_metrics AS (
    SELECT 
        years,
        COUNT(DISTINCT plan_id) as total_plans,
        -- Check digital presence metrics
        SUM(CASE WHEN marketing_url IS NOT NULL AND marketing_url != '' THEN 1 ELSE 0 END) as plans_with_marketing_url,
        SUM(CASE WHEN summary_url IS NOT NULL AND summary_url != '' THEN 1 ELSE 0 END) as plans_with_summary_url,
        SUM(CASE WHEN plan_contact IS NOT NULL AND plan_contact != '' THEN 1 ELSE 0 END) as plans_with_contact
    FROM mimi_ws_1.datahealthcaregov.plan
    GROUP BY years
),

marketing_effectiveness AS (
    SELECT
        years,
        total_plans,
        -- Calculate percentage metrics
        ROUND((plans_with_marketing_url / total_plans::float) * 100, 1) as pct_marketing_url,
        ROUND((plans_with_summary_url / total_plans::float) * 100, 1) as pct_summary_url,
        ROUND((plans_with_contact / total_plans::float) * 100, 1) as pct_contact_info
    FROM marketing_metrics
)

SELECT 
    years,
    total_plans,
    pct_marketing_url as marketing_url_coverage_pct,
    pct_summary_url as summary_url_coverage_pct,
    pct_contact_info as contact_info_coverage_pct,
    -- Create a composite digital presence score
    ROUND((pct_marketing_url + pct_summary_url + pct_contact_info) / 3, 1) as digital_presence_score
FROM marketing_effectiveness
ORDER BY years DESC;

-- How this query works:
-- 1. First CTE calculates raw counts of plans and their digital presence elements
-- 2. Second CTE converts raw counts to percentages
-- 3. Final SELECT creates a composite score and presents results by year

-- Assumptions and Limitations:
-- - Assumes empty strings and NULL values indicate missing information
-- - Treats all digital presence elements with equal weight in the composite score
-- - Does not assess the quality or effectiveness of the digital content
-- - Limited to quantitative measures of digital presence

-- Possible Extensions:
-- 1. Add URL pattern analysis to identify common marketing platforms
-- 2. Include network type in analysis to compare digital presence across network types
-- 3. Add temporal analysis to track improvement in digital presence over time
-- 4. Create segments based on digital presence score for deeper analysis
-- 5. Cross-reference with other tables to correlate digital presence with enrollment numbers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:52:58.127020
    - Additional Notes: Query focuses on digital marketing metrics and assumes URLs and contact information are key indicators of digital engagement. The digital presence score is a simplified metric that could be refined with weighted components based on business priorities.
    
    */