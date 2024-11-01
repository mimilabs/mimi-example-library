-- readmission_risk_analysis.sql

-- Business Purpose:
-- This query analyzes 30-day readmission patterns to identify high-risk patients and potential cost savings opportunities.
-- Helps care management teams prioritize interventions and reduce avoidable readmissions.
-- Key metrics: readmission rate, time between admissions, and associated costs.

WITH date_bounds AS (
    -- Get date boundaries for analysis
    SELECT 
        MIN(clm_admsn_dt) as min_date,
        DATE_SUB(MAX(clm_admsn_dt), 30) as cutoff_date
    FROM mimi_ws_1.desynpuf.inpatient_claims
),

initial_admissions AS (
    -- Get initial admissions excluding last 30 days of data to allow follow-up period
    SELECT 
        i.desynpuf_id,
        i.clm_id,
        i.clm_admsn_dt,
        i.nch_bene_dschrg_dt,
        i.clm_pmt_amt,
        i.admtng_icd9_dgns_cd,
        i.prvdr_num
    FROM mimi_ws_1.desynpuf.inpatient_claims i
    CROSS JOIN date_bounds d
    WHERE i.clm_admsn_dt <= d.cutoff_date
),

readmissions AS (
    -- Identify readmissions within 30 days
    SELECT 
        a.desynpuf_id,
        a.clm_id as initial_claim_id,
        a.clm_admsn_dt as initial_admission_date,
        a.nch_bene_dschrg_dt as initial_discharge_date,
        b.clm_id as readmit_claim_id,
        b.clm_admsn_dt as readmit_date,
        DATEDIFF(b.clm_admsn_dt, a.nch_bene_dschrg_dt) as days_to_readmit,
        a.clm_pmt_amt as initial_cost,
        b.clm_pmt_amt as readmit_cost,
        a.admtng_icd9_dgns_cd as initial_diagnosis,
        a.prvdr_num as initial_provider,
        b.prvdr_num as readmit_provider
    FROM initial_admissions a
    INNER JOIN mimi_ws_1.desynpuf.inpatient_claims b
        ON a.desynpuf_id = b.desynpuf_id
        AND b.clm_admsn_dt > a.nch_bene_dschrg_dt
        AND DATEDIFF(b.clm_admsn_dt, a.nch_bene_dschrg_dt) <= 30
)

SELECT
    COUNT(DISTINCT initial_claim_id) as total_index_admissions,
    COUNT(DISTINCT readmit_claim_id) as total_readmissions,
    ROUND(COUNT(DISTINCT readmit_claim_id) * 100.0 / COUNT(DISTINCT initial_claim_id), 2) as readmission_rate,
    ROUND(AVG(days_to_readmit), 1) as avg_days_to_readmit,
    ROUND(AVG(initial_cost), 2) as avg_initial_cost,
    ROUND(AVG(readmit_cost), 2) as avg_readmit_cost,
    ROUND(COUNT(CASE WHEN initial_provider = readmit_provider THEN 1 END) * 100.0 / 
        COUNT(*), 2) as same_facility_readmit_pct
FROM readmissions;

-- How it works:
-- 1. First CTE establishes date boundaries for analysis
-- 2. Second CTE identifies all initial admissions before the cutoff date
-- 3. Third CTE matches these with subsequent admissions within 30 days
-- 4. Final query calculates key readmission metrics

-- Assumptions and Limitations:
-- - Assumes readmissions > 30 days are not related to initial admission
-- - Does not distinguish between planned vs unplanned readmissions
-- - Does not account for deaths or transfers
-- - Limited by synthetic nature of the data

-- Possible Extensions:
-- 1. Add diagnosis-specific readmission rates
-- 2. Calculate readmission rates by provider
-- 3. Analyze seasonal patterns in readmissions
-- 4. Add risk stratification based on patient characteristics
-- 5. Calculate potential cost savings from reduced readmissions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:26:58.214051
    - Additional Notes: Query focuses on 30-day readmission analysis within Medicare inpatient claims. Performance may be impacted with very large datasets due to the self-join operation. Consider partitioning by date ranges for better performance with large datasets.
    
    */