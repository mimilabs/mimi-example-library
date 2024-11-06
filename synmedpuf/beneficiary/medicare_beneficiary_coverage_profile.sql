-- Medicare Beneficiary Demographics and Coverage Analysis
-- 
-- Business Purpose:
-- Analyze key demographic characteristics and coverage patterns of Medicare beneficiaries
-- to support population health management, care delivery planning, and program optimization.
-- This analysis helps identify opportunities for targeted interventions and resource allocation.

WITH demographic_summary AS (
    SELECT 
        -- Age grouping
        CASE 
            WHEN age_at_end_ref_yr < 65 THEN 'Under 65'
            WHEN age_at_end_ref_yr BETWEEN 65 AND 74 THEN '65-74'
            WHEN age_at_end_ref_yr BETWEEN 75 AND 84 THEN '75-84'
            ELSE '85 and older'
        END as age_group,
        
        -- Gender
        CASE sex_ident_cd 
            WHEN '1' THEN 'Male'
            WHEN '2' THEN 'Female'
            ELSE 'Unknown'
        END as gender,
        
        -- Coverage metrics
        COUNT(*) as beneficiary_count,
        
        -- Average months of different coverage types
        AVG(bene_hi_cvrage_tot_mons) as avg_part_a_months,
        AVG(bene_smi_cvrage_tot_mons) as avg_part_b_months,
        AVG(ptd_plan_cvrg_mons) as avg_part_d_months,
        AVG(dual_elgbl_mons) as avg_dual_eligible_months,
        
        -- Percentage calculations
        ROUND(100.0 * SUM(CASE WHEN dual_elgbl_mons > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_dual_eligible,
        ROUND(100.0 * SUM(CASE WHEN bene_hmo_cvrage_tot_mons > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_ma_enrolled

    FROM mimi_ws_1.synmedpuf.beneficiary
    WHERE bene_enrollmt_ref_yr = 2010  -- Focus on most recent year
    GROUP BY 1, 2
)

SELECT 
    age_group,
    gender,
    beneficiary_count,
    avg_part_a_months,
    avg_part_b_months,
    avg_part_d_months,
    avg_dual_eligible_months,
    pct_dual_eligible,
    pct_ma_enrolled
FROM demographic_summary
ORDER BY age_group, gender;

-- How this query works:
-- 1. Creates age groups and standardizes gender categories
-- 2. Calculates key coverage metrics including months of different Medicare parts
-- 3. Computes percentages for dual eligibility and Medicare Advantage enrollment
-- 4. Groups results by age and gender for strategic planning purposes

-- Assumptions and Limitations:
-- - Assumes 2010 data is most representative/recent
-- - Limited to basic demographic splits (age/gender)
-- - Doesn't account for partial year enrollments
-- - Synthetic data may not perfectly reflect real-world patterns

-- Possible Extensions:
-- 1. Add geographic analysis by state_code
-- 2. Include race/ethnicity breakdown
-- 3. Analyze trends across multiple years
-- 4. Add risk factors and chronic conditions
-- 5. Compare FFS vs MA enrollment patterns
-- 6. Analyze Part D coverage patterns in detail

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:20:37.419313
    - Additional Notes: Query focuses on 2010 data only and provides high-level demographic segmentation with coverage patterns. Memory usage may be high for large beneficiary populations due to multiple average calculations. Consider adding WHERE clauses if analyzing specific geographic regions or subsegments.
    
    */