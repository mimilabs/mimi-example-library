
-- Medicare Part B Procedure Utilization and Cost Analysis
-- Author: Healthcare Data Analytics Team
-- Date: 2023-11-15

-- Business Purpose:
-- Analyze Medicare Part B procedure utilization, cost patterns, 
-- and payment characteristics across provider specialties and services

WITH procedure_analysis AS (
    -- Aggregate key metrics by provider specialty and HCPCS code
    SELECT 
        provider_spec_cd,
        hcpcs_cd,
        COUNT(DISTINCT carrier_num) AS carrier_count,
        SUM(submitted_service_cnt) AS total_submitted_services,
        SUM(submitted_charge_amt) AS total_submitted_charges,
        SUM(allowed_charge_amt) AS total_allowed_charges,
        SUM(nch_payment_amt) AS total_medicare_payments,
        ROUND(AVG(denied_services_cnt * 1.0 / NULLIF(submitted_service_cnt, 0)) * 100, 2) AS denial_rate_pct
    FROM 
        mimi_ws_1.datacmsgov.psps
    WHERE 
        measurement_date_end >= '2020-01-01'  -- Focus on recent data
    GROUP BY 
        provider_spec_cd, 
        hcpcs_cd
)

SELECT 
    provider_spec_cd,
    hcpcs_cd,
    carrier_count,
    total_submitted_services,
    total_submitted_charges,
    total_allowed_charges,
    total_medicare_payments,
    denial_rate_pct,
    RANK() OVER (ORDER BY total_medicare_payments DESC) AS payment_rank
FROM 
    procedure_analysis
WHERE 
    total_submitted_services > 100  -- Exclude low-volume procedures
ORDER BY 
    total_medicare_payments DESC
LIMIT 50;

-- Query Methodology:
-- 1. Aggregates procedure data by provider specialty and HCPCS code
-- 2. Calculates key financial and utilization metrics
-- 3. Ranks procedures by total Medicare payments
-- 4. Filters out low-volume procedures for meaningful insights

-- Key Assumptions:
-- - Uses data from 2020 onwards
-- - Excludes procedures with less than 100 submitted services
-- - Focuses on aggregate financial characteristics

-- Potential Query Extensions:
-- 1. Add place_of_service_cd dimension
-- 2. Include time-based trending analysis
-- 3. Compare across different pricing localities
-- 4. Drill into specific provider specialty segments


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:14:14.553702
    - Additional Notes: Query performs high-level aggregation of Medicare Part B procedure data, filtering recent records and focusing on financial metrics. Suitable for initial exploration of healthcare service utilization and costs.
    
    */