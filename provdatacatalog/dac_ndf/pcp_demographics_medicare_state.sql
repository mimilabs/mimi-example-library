-- Title: Primary Care Provider Demographics and Medicare Participation Analysis

-- Business Purpose:
-- Analyzes the demographic characteristics and Medicare participation patterns of primary care physicians
-- to help healthcare organizations and policymakers:
-- 1. Understand the age distribution of PCPs based on graduation years
-- 2. Assess gender diversity in primary care
-- 3. Track Medicare assignment acceptance rates
-- 4. Identify potential succession planning needs in different regions

WITH primary_care AS (
  -- Filter for primary care providers and active Medicare participants
  SELECT 
    provider_last_name,
    provider_first_name,
    gndr,
    grd_yr,
    pri_spec,
    state,
    ind_assgn,
    grp_assgn
  FROM mimi_ws_1.provdatacatalog.dac_ndf
  WHERE pri_spec IN ('Internal Medicine', 'Family Practice', 'General Practice')
    AND grd_yr IS NOT NULL
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.provdatacatalog.dac_ndf)
)

-- Main analysis aggregating key metrics by state
SELECT 
  state,
  COUNT(*) as total_pcps,
  -- Age cohort analysis
  SUM(CASE WHEN grd_yr >= 2000 THEN 1 ELSE 0 END) as pcps_graduated_after_2000,
  ROUND(AVG(2024 - CAST(grd_yr as INT)), 1) as avg_years_since_graduation,
  -- Gender distribution
  ROUND(100.0 * SUM(CASE WHEN gndr = 'F' THEN 1 ELSE 0 END) / COUNT(*), 1) as female_pcp_percentage,
  -- Medicare participation
  ROUND(100.0 * SUM(CASE WHEN ind_assgn = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_accepting_medicare_assignment
FROM primary_care
GROUP BY state
HAVING COUNT(*) >= 20  -- Filter for states with meaningful sample sizes
ORDER BY total_pcps DESC;

-- Query Operation:
-- 1. Creates a CTE focusing on primary care providers from the most recent data
-- 2. Calculates key demographic and practice metrics by state
-- 3. Includes only states with sufficient sample size for statistical relevance

-- Assumptions and Limitations:
-- 1. Assumes graduation year is a reasonable proxy for provider age/experience
-- 2. Limited to providers who have reported graduation years
-- 3. Does not account for part-time vs full-time status
-- 4. May include some providers who are no longer actively practicing

-- Possible Extensions:
-- 1. Add trending analysis by comparing multiple mimi_src_file_dates
-- 2. Include analysis of secondary specialties
-- 3. Add geographic clustering analysis using ZIP codes
-- 4. Incorporate facility size (num_org_mem) into the analysis
-- 5. Compare urban vs rural distributions using ZIP code demographics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:34:37.626701
    - Additional Notes: Query focuses on licensed primary care physicians (Internal Medicine, Family Practice, General Practice) and their Medicare participation patterns by state. Requires recent data in the source table and meaningful state-level sample sizes (n≥20) for accurate analysis.
    
    */