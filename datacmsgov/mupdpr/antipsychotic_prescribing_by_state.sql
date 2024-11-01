-- medicare_antipsychotic_ltc_analysis.sql

-- Business Purpose: Analyze antipsychotic medication prescribing patterns in long-term care settings
-- This analysis helps:
-- 1. Monitor potentially inappropriate prescribing of antipsychotics to elderly patients
-- 2. Support quality improvement initiatives in long-term care facilities
-- 3. Identify geographical variations in prescribing practices for targeted interventions

WITH antipsychotic_drugs AS (
    -- Define common antipsychotic medications
    SELECT DISTINCT gnrc_name 
    FROM mimi_ws_1.datacmsgov.mupdpr
    WHERE LOWER(gnrc_name) LIKE '%risperidone%'
       OR LOWER(gnrc_name) LIKE '%quetiapine%'
       OR LOWER(gnrc_name) LIKE '%olanzapine%'
       OR LOWER(gnrc_name) LIKE '%aripiprazole%'
       OR LOWER(gnrc_name) LIKE '%haloperidol%'
),

provider_prescribing AS (
    -- Analyze prescribing patterns by provider and state
    SELECT 
        p.prscrbr_state_abrvtn,
        p.prscrbr_type,
        COUNT(DISTINCT p.prscrbr_npi) as provider_count,
        SUM(p.tot_clms) as total_claims,
        SUM(p.tot_benes) as total_patients,
        SUM(p.tot_drug_cst) as total_cost,
        ROUND(SUM(p.tot_drug_cst) / SUM(p.tot_clms), 2) as cost_per_claim
    FROM mimi_ws_1.datacmsgov.mupdpr p
    INNER JOIN antipsychotic_drugs a 
        ON p.gnrc_name = a.gnrc_name
    WHERE p.mimi_src_file_date = '2022-12-31'  -- Most recent year
        AND p.prscrbr_type IN ('Geriatric Medicine', 'Internal Medicine', 'Family Practice')
    GROUP BY 
        p.prscrbr_state_abrvtn,
        p.prscrbr_type
    HAVING total_claims >= 100  -- Focus on providers with significant volume
)

SELECT 
    prscrbr_state_abrvtn as state,
    prscrbr_type as specialty,
    provider_count,
    total_claims,
    total_patients,
    ROUND(total_claims * 1.0 / provider_count, 1) as claims_per_provider,
    ROUND(total_patients * 1.0 / provider_count, 1) as patients_per_provider,
    cost_per_claim
FROM provider_prescribing
ORDER BY total_claims DESC
LIMIT 50;

-- How it works:
-- 1. First CTE identifies common antipsychotic medications
-- 2. Second CTE calculates key metrics by state and provider specialty
-- 3. Final query presents the results with per-provider ratios
-- 4. Results are filtered to focus on relevant specialties and significant prescribing volume

-- Assumptions and limitations:
-- 1. Focuses only on specific antipsychotic medications (not exhaustive)
-- 2. Limited to three primary specialties most involved in geriatric care
-- 3. Requires minimum claim threshold to ensure statistical relevance
-- 4. Does not account for patient case mix or facility characteristics

-- Possible extensions:
-- 1. Add temporal trends by comparing across multiple years
-- 2. Include additional medications or drug classes
-- 3. Incorporate facility-level analysis for LTC settings
-- 4. Add benchmarking against national or regional averages
-- 5. Expand to include analysis of concurrent medications

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:38:40.585910
    - Additional Notes: Query focuses on state-level analysis of antipsychotic prescribing patterns among primary care and geriatric specialists in 2022, with metrics normalized by provider count. Results are limited to providers with at least 100 claims for better statistical significance.
    
    */