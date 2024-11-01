-- Teaching Hospital Network Analysis
-- ==========================================
-- Business Purpose: Analyze the distribution and characteristics of major teaching hospitals 
-- within health systems to understand:
-- - Academic medical center presence across health systems
-- - Relationship between teaching status and care for underserved populations
-- - Training capacity and healthcare workforce development

WITH teaching_metrics AS (
    SELECT 
        -- Basic health system info
        health_sys_name,
        health_sys_state,
        sys_teachint,
        sys_res,
        
        -- Teaching hospital indicators
        sys_incl_majteachhosp,
        sys_incl_vmajteachhosp,
        
        -- Care for underserved populations
        sys_incl_highdpphosp,
        sys_highucburden,
        
        -- System size metrics
        hosp_cnt,
        total_mds,
        sys_beds
    FROM mimi_ws_1.ahrq.compendium_us_health_systems
    WHERE sys_incl_majteachhosp = 1  -- Focus on systems with major teaching hospitals
)

SELECT
    -- Calculate teaching intensity distribution
    COUNT(*) as total_teaching_systems,
    
    -- Training capacity metrics
    AVG(sys_res) as avg_residents_per_system,
    AVG(total_mds) as avg_physicians_per_system,
    
    -- Underserved care metrics
    SUM(sys_incl_highdpphosp) as systems_with_high_dsh,
    AVG(CAST(sys_highucburden as INT)) as pct_high_uncomp_care,
    
    -- Very major teaching presence
    SUM(sys_incl_vmajteachhosp) as systems_with_vmaj_teaching,
    
    -- System size metrics
    AVG(hosp_cnt) as avg_hospitals_per_system,
    AVG(sys_beds) as avg_beds_per_system

FROM teaching_metrics;

-- How this query works:
-- 1. Creates a CTE focusing on teaching hospital systems
-- 2. Aggregates key metrics around training capacity and care delivery
-- 3. Provides a comprehensive view of academic medical center characteristics

-- Assumptions and Limitations:
-- - Focuses only on systems with at least one major teaching hospital
-- - Teaching intensity may vary within systems
-- - Resident counts may be affected by reporting variations

-- Possible Extensions:
-- 1. Add geographic analysis of teaching hospital distribution
-- 2. Compare financial metrics between teaching and non-teaching systems
-- 3. Analyze relationship between teaching status and insurance offerings
-- 4. Track changes in teaching capacity over time
-- 5. Examine correlation between teaching status and participation in value-based care models

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:42:27.389868
    - Additional Notes: Query focuses on academic medical centers and provides insights into teaching hospital distribution, capacity, and care for underserved populations. Note that systems without major teaching hospitals are excluded from the analysis, which may limit the comparative analysis potential.
    
    */