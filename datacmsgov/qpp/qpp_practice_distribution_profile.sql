-- QPP Practice Profile Analysis - Identifying High-Impact Practice Characteristics
-- Business Purpose: Analyze key characteristics of medical practices participating in QPP
-- to understand geographical distribution, practice settings, and patient populations served.
-- This helps identify where to focus provider outreach and support resources.

WITH practice_summary AS (
  -- Aggregate metrics by practice location and size
  SELECT 
    practice_state_or_us_territory,
    practice_size,
    COUNT(DISTINCT provider_key) as provider_count,
    COUNT(DISTINCT CASE WHEN health_professional_shortage_area_status = 'Y' THEN provider_key END) as hpsa_providers,
    AVG(CAST(medicare_patients AS FLOAT)) as avg_medicare_patients,
    AVG(CAST(allowed_charges AS FLOAT)) as avg_allowed_charges,
    AVG(CAST(dual_eligibility_ratio AS FLOAT)) as avg_dual_eligible_ratio
  FROM mimi_ws_1.datacmsgov.qpp
  WHERE practice_state_or_us_territory IS NOT NULL
  GROUP BY practice_state_or_us_territory, practice_size
),

state_rankings AS (
  -- Calculate state-level rankings based on provider counts
  SELECT 
    practice_state_or_us_territory,
    SUM(provider_count) as total_providers,
    SUM(hpsa_providers) as total_hpsa_providers,
    AVG(avg_medicare_patients) as state_avg_medicare_patients,
    RANK() OVER (ORDER BY SUM(provider_count) DESC) as provider_rank
  FROM practice_summary
  GROUP BY practice_state_or_us_territory
)

-- Combine practice and state metrics for final analysis
SELECT 
  ps.practice_state_or_us_territory,
  ps.practice_size,
  ps.provider_count,
  ps.hpsa_providers,
  ROUND(ps.hpsa_providers * 100.0 / ps.provider_count, 1) as pct_hpsa,
  ROUND(ps.avg_medicare_patients, 0) as avg_medicare_patients,
  ROUND(ps.avg_allowed_charges, 0) as avg_allowed_charges,
  ROUND(ps.avg_dual_eligible_ratio * 100, 1) as avg_dual_eligible_pct,
  sr.total_providers as state_total_providers,
  sr.provider_rank as state_rank
FROM practice_summary ps
JOIN state_rankings sr 
  ON ps.practice_state_or_us_territory = sr.practice_state_or_us_territory
ORDER BY 
  sr.provider_rank,
  ps.practice_size;

-- How it works:
-- 1. First CTE aggregates practice-level metrics by state and practice size
-- 2. Second CTE calculates state-level totals and rankings
-- 3. Final query joins these together to show combined view of practice characteristics
-- 4. Results ordered by state ranking and practice size for easy analysis

-- Assumptions and Limitations:
-- - Assumes practice_state_or_us_territory and practice_size are well-populated
-- - Null values in medicare_patients, allowed_charges excluded from averages
-- - Practice size categories are pre-defined in source data
-- - HPSA status is binary Y/N

-- Possible Extensions:
-- 1. Add temporal analysis to show changes in practice characteristics over time
-- 2. Include quality scores to correlate with practice characteristics
-- 3. Add specialty mix analysis within practice sizes
-- 4. Incorporate rurality analysis
-- 5. Add geographic clustering analysis to identify practice "hot spots"/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:14:48.907439
    - Additional Notes: Query focuses on geographic and size-based distribution of QPP practices with emphasis on HPSA and dual-eligible metrics. Particularly useful for identifying underserved areas and resource allocation planning. Performance metrics intentionally excluded to focus on practice characteristics.
    
    */