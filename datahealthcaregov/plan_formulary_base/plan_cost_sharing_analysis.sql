-- Title: Healthcare Plan Cost-Sharing Affordability Analysis

-- Business Purpose:
-- This query analyzes the financial burden on patients across different health plans by:
-- - Calculating average out-of-pocket costs by pharmacy type
-- - Identifying plans with the most favorable cost-sharing structures
-- - Highlighting variations in cost-sharing approaches (copay vs coinsurance)
-- This information helps stakeholders evaluate plan affordability and identify 
-- opportunities for cost optimization.

WITH cost_metrics AS (
    SELECT 
        plan_id,
        pharmacy_type,
        -- Calculate average costs
        AVG(CASE WHEN copay_opt = 'Y' THEN copay_amount ELSE NULL END) as avg_copay,
        AVG(CASE WHEN coinsurance_opt = 'Y' THEN coinsurance_rate ELSE NULL END) as avg_coinsurance,
        -- Count cost-sharing methods
        COUNT(CASE WHEN copay_opt = 'Y' THEN 1 END) as copay_count,
        COUNT(CASE WHEN coinsurance_opt = 'Y' THEN 1 END) as coinsurance_count,
        COUNT(*) as total_drugs
    FROM mimi_ws_1.datahealthcaregov.plan_formulary_base
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.datahealthcaregov.plan_formulary_base)
    GROUP BY plan_id, pharmacy_type
)

SELECT 
    plan_id,
    pharmacy_type,
    -- Format cost metrics
    ROUND(avg_copay, 2) as avg_copay_amount,
    ROUND(avg_coinsurance, 2) as avg_coinsurance_rate,
    -- Calculate cost-sharing preference
    ROUND(copay_count * 100.0 / total_drugs, 1) as copay_percentage,
    ROUND(coinsurance_count * 100.0 / total_drugs, 1) as coinsurance_percentage,
    total_drugs
FROM cost_metrics
WHERE total_drugs >= 100  -- Filter for plans with significant drug coverage
ORDER BY pharmacy_type, avg_copay_amount;

-- How this query works:
-- 1. Creates a CTE to calculate key cost metrics per plan and pharmacy type
-- 2. Filters for most recent data using mimi_src_file_date
-- 3. Calculates averages for both copay amounts and coinsurance rates
-- 4. Determines the prevalence of each cost-sharing method
-- 5. Presents results with rounded values and percentage calculations

-- Assumptions and Limitations:
-- - Assumes current cost-sharing data is representative of actual patient costs
-- - Does not account for deductibles or out-of-pocket maximums
-- - Limited to plans with at least 100 drugs for statistical significance
-- - Does not consider drug tier influence on cost-sharing

-- Possible Extensions:
-- 1. Add drug tier analysis to understand cost variation by tier
-- 2. Compare cost-sharing across different plan years
-- 3. Include mail order availability impact on costs
-- 4. Join with plan attribute data to analyze by metal level or plan type
-- 5. Create affordability scores based on weighted cost metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:03:45.531246
    - Additional Notes: Query focuses on comparing financial accessibility across healthcare plans through cost-sharing mechanisms. Note that results are filtered for plans with 100+ drugs to ensure statistical relevance. Consider adjusting this threshold based on specific analysis needs. The averaging of copay/coinsurance rates provides a high-level view but may mask important variations within individual drug tiers.
    
    */