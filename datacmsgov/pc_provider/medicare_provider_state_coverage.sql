-- medicare_provider_enrollment_status_by_state.sql
-- 
-- Business Purpose: Analyze the current enrollment status of Medicare providers by state to:
-- 1. Track provider participation and coverage across regions
-- 2. Identify states with high/low provider enrollment ratios
-- 3. Support strategic provider network expansion decisions
-- 4. Monitor quarterly provider enrollment trends

WITH current_snapshot AS (
    -- Get the most recent data snapshot
    SELECT MAX(mimi_src_file_date) as latest_date
    FROM mimi_ws_1.datacmsgov.pc_provider
),

provider_summary AS (
    -- Calculate key metrics by state
    SELECT 
        p.state_cd,
        COUNT(DISTINCT p.npi) as total_providers,
        COUNT(DISTINCT CASE WHEN p.provider_type_cd LIKE '14-%' THEN p.npi END) as practitioner_count,
        COUNT(DISTINCT CASE WHEN p.provider_type_cd LIKE '00-%' THEN p.npi END) as part_a_provider_count,
        COUNT(DISTINCT CASE WHEN p.provider_type_cd LIKE '12-%' THEN p.npi END) as part_b_supplier_count,
        COUNT(DISTINCT p.pecos_asct_cntl_id) as unique_organizations,
        ROUND(COUNT(DISTINCT p.enrlmt_id)::DECIMAL / NULLIF(COUNT(DISTINCT p.npi), 0), 2) as avg_enrollments_per_provider
    FROM mimi_ws_1.datacmsgov.pc_provider p
    JOIN current_snapshot cs ON p.mimi_src_file_date = cs.latest_date
    WHERE p.state_cd IS NOT NULL
    GROUP BY p.state_cd
)

-- Generate final summary with rankings
SELECT 
    s.state_cd,
    s.total_providers,
    s.practitioner_count,
    s.part_a_provider_count,
    s.part_b_supplier_count,
    s.unique_organizations,
    s.avg_enrollments_per_provider,
    RANK() OVER (ORDER BY s.total_providers DESC) as provider_count_rank,
    RANK() OVER (ORDER BY s.avg_enrollments_per_provider DESC) as enrollment_intensity_rank
FROM provider_summary s
ORDER BY s.total_providers DESC;

-- How this query works:
-- 1. Identifies the most recent data snapshot to ensure consistency
-- 2. Calculates key provider enrollment metrics by state
-- 3. Includes different provider types (practitioners, Part A providers, Part B suppliers)
-- 4. Computes the average number of enrollments per provider
-- 5. Ranks states by total provider count and enrollment intensity
--
-- Assumptions and limitations:
-- - Assumes current snapshot represents active enrollments
-- - Does not account for provider capacity or patient population
-- - State-level analysis may mask local market variations
-- - Does not consider provider specialty mix within states
--
-- Possible extensions:
-- 1. Add year-over-year comparison of provider counts
-- 2. Include population-adjusted provider ratios
-- 3. Break down analysis by metropolitan vs rural areas
-- 4. Add provider specialty mix analysis
-- 5. Compare state-level statistics to national averages

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:18:55.893153
    - Additional Notes: Query focuses on provider network coverage metrics at the state level, particularly useful for network adequacy assessment and strategic planning. Consider adding provider-to-population ratios for more meaningful state comparisons.
    
    */