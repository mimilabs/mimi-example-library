-- Health System Care Delivery Model Analysis
-- ==========================================
-- Business Purpose: Analyze how health systems are structured to deliver care by examining:
-- - Integration of insurance products and value-based care models
-- - Balance of facilities across the care continuum
-- - Financial scale of operations
-- This helps identify different strategic approaches to healthcare delivery and market positioning.

WITH system_segments AS (
  SELECT
    -- Basic identifiers
    health_sys_id,
    health_sys_name,
    
    -- Care delivery capabilities
    ROUND(total_mds/NULLIF(hosp_cnt, 0), 1) as physicians_per_hospital,
    ROUND(100.0 * prim_care_mds/NULLIF(total_mds, 0), 1) as pct_primary_care,
    ROUND(100.0 * nh_cnt/NULLIF(hosp_cnt, 0), 1) as nursing_homes_per_100_hospitals,
    
    -- Insurance integration
    CASE 
      WHEN sys_anyins_product = 1 AND sys_ma_plan_enroll > 50000 THEN 'Large Insurer'
      WHEN sys_anyins_product = 1 THEN 'Insurance Product Owner'
      ELSE 'Provider Only'
    END as insurance_model,
    
    -- Value-based care adoption
    CASE 
      WHEN sys_apm = 1 AND sys_aco = 1 THEN 'Full Value-Based'
      WHEN sys_apm = 1 OR sys_aco = 1 THEN 'Partial Value-Based'
      ELSE 'Traditional Payment'
    END as payment_model,
    
    -- Financial scale
    ROUND(hos_net_revenue/1000000, 1) as revenue_millions,
    ROUND(hos_net_revenue/NULLIF(hosp_cnt, 0)/1000000, 1) as revenue_per_hospital_millions

  FROM mimi_ws_1.ahrq.compendium_us_health_systems
  WHERE hosp_cnt > 0  -- Focus on active systems
)

SELECT
  insurance_model,
  payment_model,
  COUNT(*) as system_count,
  ROUND(AVG(physicians_per_hospital), 1) as avg_physicians_per_hospital,
  ROUND(AVG(pct_primary_care), 1) as avg_pct_primary_care,
  ROUND(AVG(nursing_homes_per_100_hospitals), 1) as avg_nursing_homes_ratio,
  ROUND(AVG(revenue_per_hospital_millions), 1) as avg_revenue_per_hospital_m
FROM system_segments
GROUP BY insurance_model, payment_model
ORDER BY insurance_model, payment_model;

-- How this works:
-- 1. Creates segments based on insurance integration and value-based care adoption
-- 2. Calculates key ratios for care delivery structure
-- 3. Aggregates metrics by segment to show different business models

-- Assumptions and limitations:
-- - Assumes missing values don't significantly impact categorization
-- - Revenue figures only include hospital operations
-- - Simple categorization may not capture full complexity of business models

-- Possible extensions:
-- 1. Add trend analysis across multiple years
-- 2. Include geographic variation in business models
-- 3. Analyze correlation with quality metrics or patient outcomes
-- 4. Compare financial performance across different models
-- 5. Add market share analysis within each segment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:09:48.275885
    - Additional Notes: Query segments health systems by insurance integration and value-based care adoption, providing normalized metrics for comparing different healthcare delivery approaches. Revenue calculations may be incomplete for systems with significant non-hospital operations. Primary care ratios should be validated against industry benchmarks.
    
    */