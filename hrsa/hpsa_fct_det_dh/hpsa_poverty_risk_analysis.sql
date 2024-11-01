-- Title: Dental HPSA Socioeconomic Impact Assessment
--
-- Business Purpose:
-- Analyzes the relationship between poverty levels and dental care shortages
-- to identify high-need areas where social determinants may be amplifying
-- healthcare access challenges. This insight helps prioritize interventions
-- and resource allocation for vulnerable populations.

-- Main Query
WITH poverty_shortage_metrics AS (
  SELECT 
    common_state_name,
    designation_type,
    -- Calculate average metrics per state and designation type
    COUNT(DISTINCT hpsa_id) as total_hpsas,
    ROUND(AVG(pct_of_population_below_100pct_poverty), 1) as avg_poverty_pct,
    ROUND(AVG(hpsa_score), 1) as avg_hpsa_score,
    ROUND(AVG(hpsa_fte), 1) as avg_providers_needed,
    SUM(hpsa_designation_population) as total_impacted_population
  FROM mimi_ws_1.hrsa.hpsa_fct_det_dh
  WHERE hpsa_status = 'Designated'
    AND pct_of_population_below_100pct_poverty IS NOT NULL
  GROUP BY common_state_name, designation_type
)

SELECT 
  common_state_name,
  designation_type,
  total_hpsas,
  avg_poverty_pct,
  avg_hpsa_score,
  avg_providers_needed,
  total_impacted_population,
  -- Classify severity based on combined factors
  CASE 
    WHEN avg_poverty_pct >= 30 AND avg_hpsa_score >= 15 THEN 'High Risk'
    WHEN avg_poverty_pct >= 20 OR avg_hpsa_score >= 10 THEN 'Moderate Risk'
    ELSE 'Lower Risk'
  END as risk_category
FROM poverty_shortage_metrics
ORDER BY avg_poverty_pct DESC, avg_hpsa_score DESC;

-- How it works:
-- 1. Filters for active HPSA designations with valid poverty data
-- 2. Aggregates key metrics by state and designation type
-- 3. Calculates average poverty levels, HPSA scores, and provider needs
-- 4. Assigns risk categories based on combined poverty and shortage severity
-- 5. Orders results to highlight highest-need areas first

-- Assumptions and Limitations:
-- - Assumes current HPSA designations are up-to-date
-- - Limited to areas with reported poverty data
-- - Risk categories use simplified thresholds that may need adjustment
-- - Does not account for temporal changes or seasonal variations

-- Possible Extensions:
-- 1. Add time-based trending of poverty and shortage metrics
-- 2. Include additional social determinants (education, insurance status)
-- 3. Create geographic clusters of high-risk areas
-- 4. Compare with state/federal funding allocation data
-- 5. Incorporate population demographic factors for deeper analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:51:56.513473
    - Additional Notes: Query focuses on poverty-linked dental shortages across different designation types. Results are most meaningful for states with complete poverty reporting. The risk categorization thresholds (30%/15 for high risk, 20%/10 for moderate) may need adjustment based on specific program requirements or regional standards.
    
    */