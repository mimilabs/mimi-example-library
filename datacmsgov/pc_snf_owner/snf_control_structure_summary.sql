-- snf_operational_control.sql
-- Analyzes the operational control structure of Skilled Nursing Facilities (SNFs)
-- by examining the distribution and concentration of ownership roles
--
-- Business Purpose:
-- - Identify key decision makers and operational controllers in SNFs
-- - Understand the governance models across facilities
-- - Support due diligence for partnerships and network development

WITH ownership_summary AS (
    -- Aggregate ownership information by facility
    SELECT 
        organization_name,
        COUNT(DISTINCT associate_id_owner) as total_owners,
        SUM(CASE WHEN role_text_owner LIKE '%MANAGING%' THEN 1 ELSE 0 END) as managing_controllers,
        SUM(CASE WHEN role_text_owner LIKE '%OPERATIONAL%' THEN 1 ELSE 0 END) as operational_controllers,
        SUM(CASE WHEN percentage_ownership >= 5.0 THEN 1 ELSE 0 END) as significant_owners,
        MAX(percentage_ownership) as max_ownership_percentage,
        COUNT(DISTINCT role_text_owner) as distinct_control_roles
    FROM mimi_ws_1.datacmsgov.pc_snf_owner
    GROUP BY organization_name
),

control_classification AS (
    -- Classify facilities based on control structure
    SELECT 
        *,
        CASE 
            WHEN managing_controllers = 0 THEN 'No Managing Control'
            WHEN managing_controllers = 1 THEN 'Single Controller'
            ELSE 'Multiple Controllers'
        END as control_model,
        CASE
            WHEN max_ownership_percentage >= 50.0 THEN 'Majority Controlled'
            WHEN max_ownership_percentage >= 25.0 THEN 'Significant Control'
            ELSE 'Distributed Control'
        END as ownership_model
    FROM ownership_summary
)

SELECT 
    control_model,
    ownership_model,
    COUNT(*) as facility_count,
    ROUND(AVG(total_owners), 1) as avg_owners_per_facility,
    ROUND(AVG(significant_owners), 1) as avg_significant_owners,
    ROUND(AVG(max_ownership_percentage), 1) as avg_max_ownership_pct,
    ROUND(AVG(distinct_control_roles), 1) as avg_control_roles
FROM control_classification
GROUP BY control_model, ownership_model
ORDER BY facility_count DESC;

-- How this query works:
-- 1. First CTE aggregates ownership metrics per facility
-- 2. Second CTE classifies facilities based on control structure
-- 3. Final query summarizes facilities by control and ownership models
--
-- Assumptions:
-- - Managing/Operational control roles are identified by keyword matching
-- - 5% ownership threshold for significant ownership
-- - 25% threshold for significant control
-- - 50% threshold for majority control
--
-- Limitations:
-- - Does not account for indirect ownership
-- - Role text matching may miss some variations
-- - Time dimension not considered
--
-- Possible Extensions:
-- - Add geographic analysis by state
-- - Include temporal analysis of control changes
-- - Analyze relationship between control structure and facility size
-- - Cross-reference with quality metrics
-- - Examine patterns in facility specializations by control type

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:18:06.738116
    - Additional Notes: Query provides a high-level overview of SNF control patterns by analyzing ownership percentages and management roles. Results are aggregated to show the distribution of different control models (single vs multiple controllers) and ownership concentration levels. The metrics focus on direct ownership only and may not capture complex organizational hierarchies or indirect control relationships.
    
    */