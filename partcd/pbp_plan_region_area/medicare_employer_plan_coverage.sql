-- Title: Medicare Employer Group Health Plan Coverage Analysis
-- Business Purpose: 
-- Analyzes the distribution and trends of employer-sponsored Medicare Advantage plans (EGHP)
-- across regions to understand:
-- - Corporate market penetration in Medicare Advantage space
-- - Geographic variation in employer-sponsored coverage
-- - Potential opportunities for expanding employer partnerships
-- This helps stakeholders target employer engagement strategies and identify growth markets.

WITH employer_plans AS (
    -- Get the most recent data for each contract/plan combination
    SELECT DISTINCT
        contract_id,
        plan_id,
        contract_year,
        eghp_flag,
        region,
        pbp_a_plan_type,
        orgtype
    FROM mimi_ws_1.partcd.pbp_plan_region_area
    WHERE eghp_flag = 'Y' 
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY contract_id, plan_id 
        ORDER BY mimi_src_file_date DESC
    ) = 1
)

SELECT 
    contract_year,
    region,
    pbp_a_plan_type,
    orgtype,
    COUNT(DISTINCT CONCAT(contract_id, plan_id)) as num_employer_plans,
    COUNT(DISTINCT contract_id) as num_unique_carriers
FROM employer_plans
WHERE contract_year >= 2020
GROUP BY 1,2,3,4
HAVING num_employer_plans > 0
ORDER BY contract_year DESC, num_employer_plans DESC;

-- How this query works:
-- 1. Creates a CTE to get latest version of each employer plan
-- 2. Filters for plans flagged as employer group plans (EGHP)
-- 3. Aggregates counts by year, region, plan type and org type
-- 4. Shows regions with active employer plans in recent years

-- Assumptions & Limitations:
-- - Uses eghp_flag to identify employer plans
-- - Limited to recent years (2020+) for current market relevance
-- - Assumes latest source file has most accurate plan status
-- - Does not account for mid-year plan changes

-- Possible Extensions:
-- 1. Add enrollment data to see covered lives in employer plans
-- 2. Compare employer vs individual market penetration rates
-- 3. Analyze benefit designs specific to employer plans
-- 4. Track year-over-year changes in employer plan offerings
-- 5. Map corporate headquarters locations vs plan service areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:52:13.545771
    - Additional Notes: Query focuses specifically on employer-sponsored Medicare Advantage plans distribution across regions. Performance may be impacted with large datasets due to CONCAT operation in aggregation. Consider adding WHERE clauses for specific regions if analyzing targeted markets.
    
    */