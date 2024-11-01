-- rhc_owner_management_analysis.sql
-- Business Purpose:
-- Analyze ownership and management patterns of Rural Health Clinics (RHCs) to understand:
--   - Overlap between ownership and management roles
--   - Concentration of decision-making authority
--   - Professional management presence
-- Strategic Value:
--   - Identify RHCs with potential governance challenges
--   - Assess operational control distribution
--   - Support due diligence for acquisitions

WITH owner_roles AS (
    -- Get distinct owner-clinic combinations with role categorization
    SELECT 
        enrollment_id,
        organization_name,
        associate_id_owner,
        type_owner,
        CASE 
            WHEN role_text_owner LIKE '%MANAGING%' THEN 'Management'
            WHEN role_text_owner LIKE '%OWNER%' THEN 'Ownership'
            ELSE 'Other'
        END AS role_category,
        percentage_ownership,
        state_owner
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
    WHERE role_text_owner IS NOT NULL
),

role_summary AS (
    -- Aggregate roles by clinic
    SELECT 
        enrollment_id,
        organization_name,
        COUNT(DISTINCT associate_id_owner) as total_stakeholders,
        COUNT(DISTINCT CASE WHEN role_category = 'Management' THEN associate_id_owner END) as management_count,
        COUNT(DISTINCT CASE WHEN role_category = 'Ownership' THEN associate_id_owner END) as owner_count,
        COUNT(DISTINCT CASE WHEN role_category IN ('Management', 'Ownership') THEN associate_id_owner END) as dual_role_count,
        MAX(percentage_ownership) as max_ownership_pct,
        state_owner
    FROM owner_roles
    GROUP BY enrollment_id, organization_name, state_owner
)

SELECT 
    state_owner,
    COUNT(DISTINCT enrollment_id) as total_clinics,
    ROUND(AVG(total_stakeholders), 1) as avg_stakeholders_per_clinic,
    ROUND(AVG(management_count), 1) as avg_management_roles,
    ROUND(AVG(owner_count), 1) as avg_owner_roles,
    ROUND(AVG(dual_role_count), 1) as avg_dual_roles,
    ROUND(AVG(max_ownership_pct), 1) as avg_max_ownership_pct
FROM role_summary
GROUP BY state_owner
HAVING total_clinics >= 5
ORDER BY total_clinics DESC;

-- How it works:
-- 1. First CTE identifies and categorizes stakeholder roles into management/ownership
-- 2. Second CTE summarizes role counts and overlaps at the clinic level
-- 3. Final query aggregates metrics by state for meaningful patterns
--
-- Assumptions and Limitations:
-- - Role text classification may not capture all management/ownership variations
-- - Focuses on current snapshot, doesn't show historical changes
-- - State-level aggregation may mask local patterns
-- - Minimum threshold of 5 clinics per state for statistical relevance
--
-- Possible Extensions:
-- 1. Add time-based analysis of role changes using association_date_owner
-- 2. Include organizational type analysis (corporation, LLC, etc.)
-- 3. Compare rural vs urban patterns using additional geographic data
-- 4. Analyze correlation between governance structure and clinic performance
-- 5. Add filters for specific ownership thresholds or stakeholder counts

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:09:36.631406
    - Additional Notes: Query focuses on governance structure analysis across states, requiring minimum 5 clinics per state for statistical validity. Role categorization logic may need adjustment based on complete role_text_owner values in actual data. Performance may be impacted with very large datasets due to multiple aggregations.
    
    */