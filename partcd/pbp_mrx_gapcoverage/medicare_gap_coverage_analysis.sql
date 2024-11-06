/*
Medicare Advantage Prescription Drug Gap Coverage Analysis
------------------------------------------------------------------------------
Business Purpose:
Analyze the extent and characteristics of prescription drug gap coverage
across Medicare Advantage plans to support strategic product development,
market positioning, and benefit design insights.

This query provides a comprehensive view of how Medicare Advantage plans 
handle prescription drug coverage during the coverage gap (donut hole).
*/

WITH gap_coverage_summary AS (
    -- Aggregate gap coverage characteristics by plan and organization type
    SELECT 
        orgtype,
        pbp_a_plan_type,
        COUNT(DISTINCT bid_id) AS total_plans,
        
        -- Calculate percentage of plans with comprehensive gap coverage
        ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN mrx_tier_gap_cost_share = 'Full Coverage' THEN bid_id END) / 
            COUNT(DISTINCT bid_id), 
            2
        ) AS pct_full_gap_coverage,
        
        -- Analyze gap coverage by drug tier types
        ARRAY_AGG(DISTINCT mrx_tier_drug_type) AS unique_drug_types_covered,
        
        -- Identify recent data point for currency
        MAX(mimi_src_file_date) AS latest_data_point
    FROM 
        mimi_ws_1.partcd.pbp_mrx_gapcoverage
    WHERE 
        -- Filter for active plans and recent data
        mrx_tier_gap_cost_share IS NOT NULL
    GROUP BY 
        orgtype, 
        pbp_a_plan_type
)

SELECT 
    orgtype,
    pbp_a_plan_type,
    total_plans,
    pct_full_gap_coverage,
    unique_drug_types_covered,
    latest_data_point
FROM 
    gap_coverage_summary
ORDER BY 
    pct_full_gap_coverage DESC, 
    total_plans DESC;

/*
Query Mechanics:
- Aggregates Medicare Advantage plan gap coverage data
- Calculates percentage of plans with full gap coverage
- Identifies unique drug types covered in gap
- Provides organization type and plan type breakdowns

Key Assumptions:
- Data represents a single reporting period
- 'Full Coverage' indicates comprehensive gap drug coverage
- Filters remove incomplete or invalid records

Potential Extensions:
1. Add temporal analysis to track coverage changes over time
2. Integrate with premium or cost-sharing data
3. Perform geographic (state/region) breakdown of coverage
4. Correlate gap coverage with plan quality ratings

Limitations:
- Static snapshot of plan benefits
- Does not track individual beneficiary experiences
- Coverage details may change annually
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:06:13.861960
    - Additional Notes: Query provides a high-level overview of Medicare Advantage prescription drug gap coverage across different plan types and organizations. Requires careful interpretation due to the snapshot nature of the data and potential annual variations in plan benefits.
    
    */