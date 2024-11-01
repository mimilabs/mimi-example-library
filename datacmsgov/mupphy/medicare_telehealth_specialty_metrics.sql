/* medicare_telehealth_adoption_analysis.sql

Business Purpose:
Analyze the adoption and utilization of telehealth services across different provider specialties
and geographic regions to inform:
- Strategic planning for virtual care initiatives
- Provider engagement in telehealth adoption
- Geographic disparities in telehealth access
- Reimbursement patterns for virtual care

The analysis focuses on telehealth services during 2022, comparing utilization and payment
patterns across provider types and locations.
*/

WITH telehealth_claims AS (
    -- Identify telehealth services based on place of service and common telehealth HCPCS codes
    SELECT 
        rndrng_prvdr_type,
        rndrng_prvdr_state_abrvtn,
        rndrng_prvdr_ruca_desc,
        COUNT(DISTINCT rndrng_npi) as provider_count,
        SUM(tot_benes) as total_beneficiaries,
        SUM(tot_srvcs) as total_services,
        AVG(avg_mdcr_pymt_amt) as avg_payment_per_service
    FROM mimi_ws_1.datacmsgov.mupphy
    WHERE mimi_src_file_date = '2022-12-31'
    AND (
        -- Telehealth place of service or common telehealth codes
        place_of_srvc = 'O' 
        AND hcpcs_cd IN (
            '99441','99442','99443', -- Telephone services
            '99201','99202','99203','99204','99205', -- New patient telehealth
            '99211','99212','99213','99214','99215'  -- Established patient telehealth
        )
    )
    GROUP BY 1,2,3
),

specialty_summary AS (
    -- Calculate specialty-level metrics
    SELECT 
        rndrng_prvdr_type,
        SUM(provider_count) as total_providers,
        SUM(total_beneficiaries) as total_patients,
        SUM(total_services) as total_encounters,
        AVG(avg_payment_per_service) as avg_payment
    FROM telehealth_claims
    GROUP BY 1
)

-- Final output combining top specialties and their metrics
SELECT 
    rndrng_prvdr_type as provider_specialty,
    total_providers,
    total_patients,
    total_encounters,
    ROUND(avg_payment, 2) as avg_payment_per_service,
    ROUND(total_encounters::float / total_providers, 1) as services_per_provider,
    ROUND(total_patients::float / total_providers, 1) as patients_per_provider
FROM specialty_summary
WHERE total_providers >= 100  -- Focus on specialties with meaningful sample size
ORDER BY total_encounters DESC
LIMIT 15;

/* How this query works:
1. First CTE identifies telehealth services using specific HCPCS codes and place of service
2. Second CTE aggregates data at the specialty level
3. Final query calculates key performance metrics per specialty

Assumptions and limitations:
- Relies on specific HCPCS codes to identify telehealth services
- Limited to Medicare FFS claims data
- May not capture all telehealth services due to coding variations
- 2022 data only - doesn't show longitudinal trends

Possible extensions:
1. Add year-over-year comparison to show telehealth adoption trends
2. Include geographic analysis by state or RUCA codes
3. Compare telehealth vs. in-person service patterns
4. Add cost analysis comparing telehealth to traditional visits
5. Segment analysis by provider credentials or gender
6. Include quality metrics if available in other linked datasets
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:21:54.010799
    - Additional Notes: Query focuses on provider specialty-level telehealth adoption metrics using 2022 Medicare claims data. The HCPCS code list used for identifying telehealth services may need periodic updates as new codes are introduced or retired. The 100-provider threshold for specialty inclusion may need adjustment based on specific analysis needs.
    
    */