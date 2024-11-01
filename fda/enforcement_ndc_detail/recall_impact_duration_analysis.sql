-- Title: Drug Recall Longitudinal Analysis by Event
-- Business Purpose:
-- This query analyzes the timeline and scope of drug recall events by:
-- 1. Identifying recall events affecting multiple NDC packages
-- 2. Measuring the time span of recall activities
-- 3. Highlighting potential supply chain disruption risks through multi-package recalls
-- This helps stakeholders understand the breadth and timing of recall impacts

WITH recall_metrics AS (
    -- Calculate metrics per recall event
    SELECT 
        recall_number,
        COUNT(DISTINCT package_ndc) as affected_packages,
        COUNT(DISTINCT product_ndc) as affected_products,
        MIN(mimi_src_file_date) as first_reported_date,
        MAX(mimi_src_file_date) as last_reported_date,
        DATEDIFF(day, MIN(mimi_src_file_date), MAX(mimi_src_file_date)) as recall_duration_days
    FROM mimi_ws_1.fda.enforcement_ndc_detail
    GROUP BY recall_number
),
significant_recalls AS (
    -- Identify recalls affecting multiple packages
    SELECT *,
        CASE 
            WHEN affected_packages >= 5 THEN 'High Impact'
            WHEN affected_packages >= 2 THEN 'Medium Impact'
            ELSE 'Single Package'
        END as recall_impact
    FROM recall_metrics
    WHERE recall_duration_days > 0  -- Focus on recalls spanning multiple days
)
SELECT 
    recall_impact,
    COUNT(*) as recall_count,
    AVG(affected_packages) as avg_packages_affected,
    AVG(recall_duration_days) as avg_duration_days,
    MIN(first_reported_date) as earliest_recall,
    MAX(last_reported_date) as latest_recall
FROM significant_recalls
GROUP BY recall_impact
ORDER BY 
    CASE recall_impact 
        WHEN 'High Impact' THEN 1
        WHEN 'Medium Impact' THEN 2
        ELSE 3 
    END;

-- How it works:
-- 1. First CTE (recall_metrics) aggregates basic metrics for each recall event
-- 2. Second CTE (significant_recalls) categorizes recalls by their impact level
-- 3. Final query summarizes the patterns by impact category

-- Assumptions and Limitations:
-- 1. Uses package_ndc count as proxy for recall impact
-- 2. Assumes mimi_src_file_date reflects actual recall timeline
-- 3. Does not account for recall severity classification
-- 4. May underestimate impact if NDC data is incomplete

-- Possible Extensions:
-- 1. Join with enforcement base table to include recall classification
-- 2. Add seasonal analysis of recall patterns
-- 3. Include product-level categorization
-- 4. Add geographic impact analysis if available
-- 5. Calculate rolling averages for trend analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:20:07.125687
    - Additional Notes: Query focuses on temporal aspects and package impact levels of drug recalls. Defines impact levels (High/Medium/Single) based on affected package counts. Consider adjusting the impact level thresholds (currently set at 5+ and 2+ packages) based on specific business requirements. Duration calculations assume mimi_src_file_date is a reliable indicator of recall timeline.
    
    */