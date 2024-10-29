-- Antipsychotic Prescribing Analysis in Elderly Medicare Population
--
-- Business Purpose:
-- This query analyzes antipsychotic prescribing patterns for Medicare beneficiaries aged 65 and older.
-- It identifies prescribing volume, costs, and potential areas of concern regarding antipsychotic
-- use in elderly patients. The analysis helps identify providers and specialties with high rates
-- of antipsychotic prescribing to support medication safety initiatives and quality improvement.
--
-- Key metrics examined:
-- - Antipsychotic prescription volume and costs for elderly patients
-- - Provider specialties with high antipsychotic prescribing
-- - Geographic distribution of antipsychotic prescribing
-- - Patient demographic factors

SELECT 
    p.prscrbr_type,
    p.prscrbr_state_abrvtn,
    COUNT(DISTINCT p.prscrbr_npi) as provider_count,
    
    -- Antipsychotic prescribing metrics
    SUM(CAST(p.antpsyct_ge65_tot_clms AS FLOAT)) as total_antipsych_claims,
    SUM(CAST(p.antpsyct_ge65_tot_drug_cst AS FLOAT)) as total_antipsych_cost,
    SUM(CAST(p.antpsyct_ge65_tot_benes AS FLOAT)) as total_antipsych_patients,
    
    -- Calculate average metrics per provider
    AVG(CAST(p.antpsyct_ge65_tot_clms AS FLOAT)) as avg_antipsych_claims_per_provider,
    AVG(CAST(p.antpsyct_ge65_tot_drug_cst AS FLOAT)) as avg_antipsych_cost_per_provider,
    
    -- Patient demographic metrics
    AVG(CAST(p.bene_avg_age AS FLOAT)) as avg_patient_age,
    SUM(CAST(p.bene_dual_cnt AS FLOAT)) / SUM(CAST(p.tot_benes AS FLOAT)) as pct_dual_eligible

FROM mimi_ws_1.datacmsgov.mupdpr_prvdr p
WHERE 
    -- Focus on most recent year
    p.mimi_src_file_date = '2022-12-31'
    -- Exclude rows with suppressed data
    AND p.antpsyct_ge65_sprsn_flag IS NULL
    AND p.antpsyct_ge65_tot_clms > 0

GROUP BY 
    p.prscrbr_type,
    p.prscrbr_state_abrvtn

HAVING 
    -- Filter to providers/regions with meaningful volume
    COUNT(DISTINCT p.prscrbr_npi) >= 5
    AND SUM(CAST(p.antpsyct_ge65_tot_clms AS FLOAT)) >= 100

ORDER BY 
    total_antipsych_claims DESC;

-- Query Operation:
-- 1. Filters to most recent year of data (2022)
-- 2. Excludes suppressed data rows
-- 3. Aggregates key antipsychotic prescribing metrics by provider specialty and state
-- 4. Calculates per-provider averages and patient demographic metrics
-- 5. Filters to specialties/regions with sufficient volume for meaningful analysis

-- Assumptions & Limitations:
-- - Relies on accurate coding of antipsychotic medications
-- - Excludes suppressed data which may impact completeness
-- - Does not account for clinical appropriateness of prescribing
-- - Limited to Medicare Part D population

-- Possible Extensions:
-- 1. Add trending over multiple years
-- 2. Include analysis of specific antipsychotic medications
-- 3. Compare to overall prescribing patterns
-- 4. Add risk-adjustment based on patient demographics
-- 5. Incorporate quality metrics or outcomes data
-- 6. Add geographic analysis at more granular level

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:29:29.624929
    - Additional Notes: Query focuses specifically on providers prescribing antipsychotics to Medicare beneficiaries aged 65+. Results are aggregated at provider specialty and state level to identify prescribing patterns. Note that data suppression rules may impact completeness of analysis in regions/specialties with low volume.
    
    */