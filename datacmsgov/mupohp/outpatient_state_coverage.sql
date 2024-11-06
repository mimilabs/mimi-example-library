-- outpatient_regional_service_distribution.sql

-- Business Purpose:
-- Analyzes the distribution of Medicare outpatient hospital services across states
-- Compares service volumes and average payments between states
-- Helps identify regional variations in outpatient service delivery
-- Supports strategic planning for healthcare service expansion and resource allocation

WITH state_summary AS (
    -- Aggregate metrics at the state level
    SELECT 
        rndrng_prvdr_state_abrvtn as state,
        COUNT(DISTINCT rndrng_prvdr_ccn) as provider_count,
        SUM(bene_cnt) as total_beneficiaries,
        SUM(capc_srvcs) as total_services,
        ROUND(AVG(avg_mdcr_pymt_amt), 2) as avg_medicare_payment,
        ROUND(SUM(capc_srvcs * avg_mdcr_pymt_amt) / SUM(capc_srvcs), 2) as weighted_avg_payment
    FROM mimi_ws_1.datacmsgov.mupohp
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    GROUP BY rndrng_prvdr_state_abrvtn
),
state_ranks AS (
    -- Calculate rankings for each metric
    SELECT 
        state,
        provider_count,
        total_beneficiaries,
        total_services,
        avg_medicare_payment,
        weighted_avg_payment,
        RANK() OVER (ORDER BY total_services DESC) as service_volume_rank,
        RANK() OVER (ORDER BY weighted_avg_payment DESC) as payment_rank
    FROM state_summary
)
-- Final output with key metrics and rankings
SELECT 
    state,
    provider_count,
    total_beneficiaries,
    total_services,
    weighted_avg_payment,
    service_volume_rank,
    payment_rank
FROM state_ranks
ORDER BY total_services DESC;

-- How this query works:
-- 1. First CTE aggregates key metrics at the state level
-- 2. Second CTE adds rankings for service volume and payment levels
-- 3. Final output presents a comprehensive view of regional service distribution

-- Assumptions and limitations:
-- - Uses most recent year of data (2022)
-- - Assumes even distribution of services within states
-- - Does not account for population differences between states
-- - Medicare payments may not reflect total healthcare spending

-- Possible extensions:
-- 1. Add year-over-year comparison to show regional trends
-- 2. Include population adjustment factors for better state comparisons
-- 3. Break down by urban vs rural areas within states
-- 4. Add service type (APC) distribution analysis by region
-- 5. Incorporate demographic factors for deeper analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:07:03.993415
    - Additional Notes: Query provides comprehensive state-level analysis of Medicare outpatient coverage and utilization, with weighted averages accounting for service volume differences. Consider population normalization when comparing across states of different sizes.
    
    */