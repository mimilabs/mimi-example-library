-- Provider Cost and Quality Performance Analysis Across Specialties and Regions
-- Business Purpose: Identify high-performing providers based on cost efficiency and quality metrics
-- to support network optimization and value-based care initiatives for health plans and ACOs.

WITH provider_metrics AS (
    -- Calculate key performance metrics per provider
    SELECT 
        rndrng_prvdr_type,
        rndrng_prvdr_state_abrvtn,
        COUNT(DISTINCT rndrng_npi) as provider_count,
        
        -- Cost efficiency metrics
        AVG(tot_mdcr_alowd_amt/NULLIF(tot_benes,0)) as avg_cost_per_beneficiary,
        AVG(tot_mdcr_alowd_amt/NULLIF(tot_srvcs,0)) as avg_cost_per_service,
        
        -- Volume and complexity metrics  
        AVG(tot_benes) as avg_panel_size,
        AVG(bene_avg_risk_scre) as avg_risk_score,
        
        -- Quality indicators
        AVG(bene_cc_ph_diabetes_v2_pct) as diabetes_management_rate,
        AVG(bene_cc_ph_ckd_v2_pct) as ckd_management_rate,
        AVG(bene_cc_ph_hf_nonihd_v2_pct) as heart_failure_management_rate
        
    FROM mimi_ws_1.datacmsgov.mupphy_prvdr
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    AND tot_benes >= 20  -- Filter for active providers
    GROUP BY 1,2
),

ranked_specialties AS (
    -- Rank specialties by cost-efficiency within each state
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY rndrng_prvdr_state_abrvtn 
            ORDER BY avg_cost_per_beneficiary
        ) as cost_rank
    FROM provider_metrics
    WHERE provider_count >= 5  -- Ensure adequate sample size
)

-- Final output with high-value specialties
SELECT 
    rndrng_prvdr_state_abrvtn as state,
    rndrng_prvdr_type as specialty,
    provider_count,
    ROUND(avg_cost_per_beneficiary,2) as cost_per_beneficiary,
    ROUND(avg_panel_size,1) as avg_patients,
    ROUND(avg_risk_score,2) as risk_score,
    ROUND(diabetes_management_rate,1) as diabetes_rate,
    ROUND(heart_failure_management_rate,1) as hf_rate
FROM ranked_specialties 
WHERE cost_rank <= 5  -- Top 5 cost-efficient specialties per state
ORDER BY state, cost_rank;

/* How this query works:
1. Creates provider_metrics CTE to calculate key performance indicators by specialty and state
2. Creates ranked_specialties CTE to identify cost-efficient specialties within each state
3. Final output shows top performing specialties with quality and efficiency metrics

Assumptions and Limitations:
- Uses 2022 data only - trends over time not captured
- Minimum thresholds for provider count and patient panel size may need adjustment
- Cost efficiency alone doesn't capture full picture of value
- Raw rates not adjusted for patient mix beyond risk scores

Possible Extensions:
1. Add year-over-year trend analysis
2. Include additional quality metrics like readmissions
3. Create composite score combining cost and quality
4. Add geographic analytics like urban/rural comparisons
5. Segment analysis by provider organization size
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:18:50.365287
    - Additional Notes: Query identifies high-value provider specialties by state using a balanced scorecard of cost efficiency, patient volume, and chronic condition management rates. Best used for strategic network planning and value-based care program development. Requires minimum of 20 patients per provider and 5 providers per specialty for statistical reliability.
    
    */