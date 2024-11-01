-- Medicare Inpatient Length of Stay and Resource Intensity Analysis

-- Business Purpose:
-- This query examines Medicare inpatient hospital resource utilization patterns to:
-- 1. Identify variation in length of stay (LOS) and resource intensity across providers
-- 2. Compare covered vs total days to understand Medicare coverage patterns
-- 3. Calculate key efficiency metrics like average LOS and cost per day
-- 4. Support capacity planning and resource allocation decisions

WITH provider_stats AS (
  SELECT 
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    tot_dschrgs,
    tot_cvrd_days,
    tot_days,
    tot_mdcr_pymt_amt,
    -- Calculate key metrics
    ROUND(tot_days * 1.0 / NULLIF(tot_dschrgs, 0), 1) AS avg_los,
    ROUND(tot_cvrd_days * 100.0 / NULLIF(tot_days, 0), 1) AS pct_covered_days,
    ROUND(tot_mdcr_pymt_amt / NULLIF(tot_cvrd_days, 0), 2) AS medicare_pymt_per_day
  FROM mimi_ws_1.datacmsgov.mupihp_prvdr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent year
    AND tot_dschrgs >= 100 -- Focus on facilities with meaningful volume
)

SELECT
  rndrng_prvdr_state_abrvtn AS state,
  rndrng_prvdr_ccn AS provider_ccn,
  rndrng_prvdr_org_name AS provider_name,
  tot_dschrgs AS total_discharges,
  avg_los AS avg_length_of_stay,
  pct_covered_days AS pct_medicare_covered,
  medicare_pymt_per_day AS medicare_payment_per_day,
  -- Add rankings within state
  ROW_NUMBER() OVER (PARTITION BY rndrng_prvdr_state_abrvtn ORDER BY avg_los DESC) AS los_rank_in_state
FROM provider_stats
WHERE avg_los > 0 -- Remove invalid data
ORDER BY 
  rndrng_prvdr_state_abrvtn,
  avg_los DESC;

-- How this query works:
-- 1. Filters to most recent year and providers with material volume
-- 2. Calculates key metrics including average LOS and coverage rates
-- 3. Ranks providers within each state by length of stay
-- 4. Returns results organized by state and LOS ranking

-- Assumptions and Limitations:
-- 1. Uses 2022 data - results should be refreshed as new data becomes available
-- 2. Excludes low-volume providers (<100 discharges) for statistical reliability
-- 3. Medicare coverage patterns may not reflect overall hospital operations
-- 4. Simple averages don't account for case mix differences between facilities

-- Possible Extensions:
-- 1. Add case mix adjustment using HCC risk scores
-- 2. Compare metrics across urban/rural settings using RUCA codes
-- 3. Incorporate readmission rates to assess care quality
-- 4. Trend analysis across multiple years to identify patterns
-- 5. Add specialty hospital categorization and peer group comparisons

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:22:11.560467
    - Additional Notes: This query focuses on Medicare inpatient length of stay patterns and includes only facilities with 100+ annual discharges. The metrics (avg_los, pct_covered_days, medicare_pymt_per_day) provide insights into operational efficiency and Medicare coverage patterns but should be interpreted alongside case mix data for full context.
    
    */