
/*******************************************************************************
Title: Medicare Advantage Plan Service Area Analysis
 
Business Purpose:
This query analyzes the distribution of Medicare Advantage and Part D plans across
service regions to understand market coverage and identify potential access gaps.
Key metrics include plan counts by type and region to assess beneficiary choice
and market competition.

Created: 2024-02-15
*******************************************************************************/

-- Main query analyzing plan distribution across regions
WITH plan_counts AS (
    SELECT 
        contract_year,
        region,
        pbp_a_plan_type,
        region_type,
        -- Count distinct plans
        COUNT(DISTINCT CONCAT(contract_id, plan_id)) as num_plans,
        -- Count distinct contracts (organizations)
        COUNT(DISTINCT contract_id) as num_organizations
    FROM mimi_ws_1.partcd.pbp_plan_region_area
    WHERE contract_year = 2023  -- Focus on current year
        AND pending_flag = 'N'  -- Exclude pending plans
        AND eghp_flag = 'N'    -- Exclude employer group plans
    GROUP BY 
        contract_year,
        region,
        pbp_a_plan_type,
        region_type
)

SELECT 
    region,
    region_type,
    pbp_a_plan_type as plan_type,
    num_plans,
    num_organizations,
    -- Calculate avg plans per organization
    ROUND(CAST(num_plans AS FLOAT)/NULLIF(num_organizations,0),1) as avg_plans_per_org
FROM plan_counts
WHERE num_plans > 0
ORDER BY 
    region_type,
    region,
    num_plans DESC;

/*******************************************************************************
How the Query Works:
1. CTE filters to active, non-employer plans for current year
2. Aggregates distinct plans and organizations by region and plan type
3. Calculates key metrics including plans per organization
4. Orders results by region for easy analysis

Assumptions & Limitations:
- Assumes current year is 2023 (modify contract_year filter as needed)
- Excludes employer group plans which have different market dynamics
- Does not account for plan enrollment or market share
- Region definitions remain consistent within the analysis period

Possible Extensions:
1. Add year-over-year comparison to show market changes
2. Include plan benefit details to analyze coverage options
3. Join with enrollment data to show market penetration
4. Add geographic visualizations of plan availability
5. Analyze seasonal variations using mimi_src_file_date
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:36:44.218868
    - Additional Notes: Query requires 2023 data to be present in the table. For analysis of different years, modify the contract_year filter value. Performance may be impacted when analyzing multiple years simultaneously due to the DISTINCT operations on concatenated fields.
    
    */