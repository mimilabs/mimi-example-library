-- medicaid_drug_cost_trend_analysis.sql
-- Business Purpose: Analyze year-over-year drug cost trends in the Medicaid program
-- to identify opportunities for cost management and policy intervention.
-- This analysis helps states benchmark their drug spending patterns and
-- identify areas for potential cost savings.

WITH annual_costs AS (
    -- Calculate total annual drug costs by state and year
    SELECT 
        state,
        year,
        SUM(medicaid_amount_reimbursed) as total_med_cost,
        SUM(number_of_prescriptions) as total_scripts,
        COUNT(DISTINCT ndc) as unique_drugs
    FROM mimi_ws_1.datamedicaidgov.drugutilization
    WHERE state != 'XX' -- Exclude national aggregates
    AND suppression_used = FALSE -- Exclude suppressed data
    AND medicaid_amount_reimbursed > 0 -- Only include valid reimbursements
    GROUP BY state, year
),

yoy_changes AS (
    -- Calculate year-over-year changes in costs and utilization
    SELECT 
        curr.state,
        curr.year,
        curr.total_med_cost,
        curr.total_scripts,
        curr.unique_drugs,
        ROUND(((curr.total_med_cost - prev.total_med_cost) / prev.total_med_cost) * 100, 2) as cost_change_pct,
        ROUND(curr.total_med_cost / curr.total_scripts, 2) as cost_per_script
    FROM annual_costs curr
    LEFT JOIN annual_costs prev 
        ON curr.state = prev.state 
        AND curr.year = prev.year + 1
)

SELECT 
    state,
    year,
    total_med_cost,
    total_scripts,
    unique_drugs,
    cost_change_pct,
    cost_per_script
FROM yoy_changes
WHERE year >= 2018 -- Focus on recent years
ORDER BY cost_change_pct DESC, state, year;

-- How it works:
-- 1. First CTE aggregates annual costs and prescription counts by state
-- 2. Second CTE calculates year-over-year changes and per-script costs
-- 3. Final query filters to recent years and orders results by cost growth

-- Assumptions and limitations:
-- - Assumes data completeness and accuracy in reporting
-- - Excludes suppressed data which may impact smaller states
-- - Does not account for drug mix changes or inflation
-- - Limited to fee-for-service Medicaid spending

-- Possible extensions:
-- 1. Add therapeutic class analysis to identify drivers of cost growth
-- 2. Include managed care (MCO) vs fee-for-service comparison
-- 3. Add seasonal analysis by including quarter
-- 4. Incorporate drug rebate impact if data becomes available
-- 5. Add population adjustment to normalize costs across states

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:49:51.285561
    - Additional Notes: Query focuses on state-level cost trends and may not reflect complete spending patterns due to exclusion of suppressed data and MCO utilization. Cost calculations do not account for rebates or other post-purchase adjustments. Consider state population sizes when interpreting results.
    
    */