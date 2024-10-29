-- rhc_ownership_type_transitions.sql

-- Business Purpose:
-- Analyze changes in RHC ownership types over time to understand:
-- - Transitions between individual and organizational ownership
-- - Duration of ownership arrangements 
-- - Patterns in ownership changes that may indicate industry consolidation
-- This analysis helps healthcare investors and policy makers understand 
-- - ownership stability and market dynamics in rural healthcare delivery

WITH ownership_periods AS (
    -- Get ownership transition periods for each RHC
    SELECT 
        enrollment_id,
        organization_name,
        type_owner,
        association_date_owner,
        LEAD(association_date_owner) OVER (
            PARTITION BY enrollment_id 
            ORDER BY association_date_owner
        ) as next_association_date,
        -- Capture key owner details
        CASE 
            WHEN type_owner = 'I' THEN CONCAT(first_name_owner, ' ', last_name_owner)
            ELSE organization_name_owner
        END as owner_name,
        percentage_ownership,
        role_text_owner
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
    WHERE association_date_owner IS NOT NULL
),

transition_summary AS (
    -- Analyze ownership duration and transitions
    SELECT
        enrollment_id,
        organization_name,
        type_owner,
        owner_name,
        association_date_owner,
        next_association_date,
        -- Calculate ownership duration in months
        DATEDIFF(month, association_date_owner, 
                COALESCE(next_association_date, CURRENT_DATE)) as ownership_months,
        percentage_ownership,
        role_text_owner
    FROM ownership_periods
)

-- Final summary of ownership transitions and duration
SELECT 
    organization_name,
    type_owner,
    COUNT(*) as transition_count,
    AVG(ownership_months) as avg_ownership_duration_months,
    AVG(percentage_ownership) as avg_ownership_percentage,
    -- Group ownership roles using collect_set instead of STRING_AGG
    collect_set(role_text_owner) as unique_owner_roles
FROM transition_summary
WHERE ownership_months > 0
GROUP BY organization_name, type_owner
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- How this query works:
-- 1. Creates ownership_periods CTE to identify sequential ownership records
-- 2. Creates transition_summary CTE to calculate ownership durations
-- 3. Produces final summary showing ownership transition patterns

-- Assumptions and Limitations:
-- - Assumes association_date_owner represents start of ownership period
-- - Missing association dates are excluded
-- - Current date used as end date for latest ownership period
-- - Only includes RHCs with multiple ownership records

-- Possible Extensions:
-- 1. Add geographic analysis of ownership transitions
-- 2. Include financial performance correlation with ownership changes
-- 3. Analyze seasonal patterns in ownership transitions
-- 4. Compare transition patterns between different owner organization types
-- 5. Add risk scoring for facilities with frequent ownership changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:29:11.353399
    - Additional Notes: Query analyzes ownership duration patterns and transitions for Rural Health Clinics. Limited to facilities with multiple ownership records. DATEDIFF function assumes month-based calculations may vary slightly depending on the specific dates involved. The collect_set function returns an array of unique values which may need to be processed further for reporting purposes.
    
    */