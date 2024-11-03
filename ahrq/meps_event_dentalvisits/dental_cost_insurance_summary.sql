-- dental_visit_cost_analysis.sql
-- Purpose: Analyze dental care financial burden and insurance coverage patterns to:
-- 1. Identify average out-of-pocket costs per visit
-- 2. Compare insurance vs self-pay patterns
-- 3. Assess cost variations by procedure type
-- This insight helps understand affordability and coverage gaps in dental care

WITH cost_by_visit AS (
    -- Calculate total costs and payment sources for each visit
    SELECT 
        dvdateyr as year,
        dvsf_yy_x as self_pay,
        dvpv_yy_x as private_insurance,
        dvmd_yy_x as medicaid,
        dvmr_yy_x as medicare,
        dvxp_yy_x as total_payment,
        dvtc_yy_x as total_charge,
        -- Flag common procedures
        CASE WHEN examine = 1 THEN 1 ELSE 0 END as is_exam,
        CASE WHEN clenteth = 1 THEN 1 ELSE 0 END as is_cleaning,
        CASE WHEN filling = 1 THEN 1 ELSE 0 END as is_filling
    FROM mimi_ws_1.ahrq.meps_event_dentalvisits
    WHERE dvtc_yy_x > 0  -- Focus on visits with valid charges
)

SELECT 
    year,
    COUNT(*) as visit_count,
    -- Cost metrics
    ROUND(AVG(total_charge), 2) as avg_total_charge,
    ROUND(AVG(total_payment), 2) as avg_total_paid,
    ROUND(AVG(self_pay), 2) as avg_self_pay,
    -- Insurance coverage patterns
    ROUND(AVG(CASE WHEN private_insurance > 0 THEN 1 ELSE 0 END) * 100, 1) as pct_private_insurance,
    ROUND(AVG(CASE WHEN medicaid > 0 THEN 1 ELSE 0 END) * 100, 1) as pct_medicaid,
    -- Self-pay burden
    ROUND(AVG(self_pay / NULLIF(total_payment, 0)) * 100, 1) as avg_self_pay_pct
FROM cost_by_visit
GROUP BY year
ORDER BY year;

/* How this works:
1. Creates a CTE to normalize cost fields and flag common procedures
2. Calculates key financial metrics including averages and percentages
3. Groups results by year to show trends

Assumptions and limitations:
- Excludes visits with $0 total charges (may be data quality issues)
- Does not account for population weights
- Insurance coverage is simplified to presence/absence
- Cost fields may have different definitions across years

Possible extensions:
1. Add procedure-specific cost analysis
2. Include geographic variation in costs
3. Compare costs for preventive vs restorative care
4. Analyze impact of multiple insurance coverage
5. Add demographic factors to identify disparities in out-of-pocket costs
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:02:40.924546
    - Additional Notes: Query focuses on financial metrics by aggregating visit costs and insurance coverage rates annually. Cost calculations exclude zero-charge visits which may affect completeness. Consider adding population weights (perwt_yy_f) for more accurate national estimates.
    
    */