-- Title: Outpatient Visit Payment Source Analysis Across Years
-- Business Purpose: 
-- This query analyzes the distribution of payment sources for outpatient visits to:
-- 1. Identify the primary payers for outpatient services
-- 2. Track shifts in payment responsibility over time
-- 3. Support strategic planning for revenue cycle management
-- 4. Guide payer contract negotiations
-- 5. Understand patient financial burden through out-of-pocket expenses

WITH payment_summary AS (
    SELECT 
        opdateyr as visit_year,
        -- Calculate total payments by source
        SUM(opfsf_yy_x + opdsf_yy_x) as total_patient_paid,
        SUM(opfmr_yy_x + opdmr_yy_x) as total_medicare_paid,
        SUM(opfmd_yy_x + opdmd_yy_x) as total_medicaid_paid,
        SUM(opfpv_yy_x + opdpv_yy_x) as total_private_ins_paid,
        SUM(opfva_yy_x + opdva_yy_x + opftr_yy_x + opdtr_yy_x) as total_va_tricare_paid,
        SUM(opxp_yy_x) as total_payments,
        COUNT(*) as visit_count
    FROM mimi_ws_1.ahrq.meps_event_outpatientvisits
    WHERE opdateyr >= 2018  -- Focus on recent years
    GROUP BY opdateyr
)

SELECT 
    visit_year,
    visit_count,
    -- Calculate payment source percentages
    ROUND(100.0 * total_patient_paid / total_payments, 1) as pct_patient_paid,
    ROUND(100.0 * total_medicare_paid / total_payments, 1) as pct_medicare_paid,
    ROUND(100.0 * total_medicaid_paid / total_payments, 1) as pct_medicaid_paid,
    ROUND(100.0 * total_private_ins_paid / total_payments, 1) as pct_private_ins_paid,
    ROUND(100.0 * total_va_tricare_paid / total_payments, 1) as pct_va_tricare_paid,
    -- Calculate average payments
    ROUND(total_payments / visit_count, 0) as avg_payment_per_visit,
    ROUND(total_patient_paid / visit_count, 0) as avg_patient_paid_per_visit
FROM payment_summary
ORDER BY visit_year;

-- How the Query Works:
-- 1. Creates a CTE to summarize payments by source and year
-- 2. Calculates percentage distribution of payments across payer types
-- 3. Computes key metrics like average payments per visit
-- 4. Orders results chronologically to show trends

-- Assumptions and Limitations:
-- 1. Assumes payment fields are properly populated and reconciled
-- 2. Does not account for complex payment arrangements or adjustments
-- 3. Limited to available years in the dataset
-- 4. Combines facility and doctor payments for each source
-- 5. VA and TRICARE combined due to similar federal healthcare programs

-- Possible Extensions:
-- 1. Add geographic analysis by incorporating regional variables
-- 2. Break down by visit type or specialty
-- 3. Include analysis of denied claims or write-offs
-- 4. Compare telehealth vs in-person visit payment patterns
-- 5. Analyze seasonal payment patterns within years
-- 6. Add statistical tests for trend significance

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:19:53.850349
    - Additional Notes: Query provides a high-level analysis of payment source distributions and averages for outpatient visits. Limited to years 2018 and later, and combines facility/doctor payments for cleaner aggregation. Best used for understanding broad payment trends rather than detailed financial analysis.
    
    */