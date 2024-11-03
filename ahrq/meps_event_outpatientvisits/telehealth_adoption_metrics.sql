-- Title: Outpatient Visit Telehealth Adoption Analysis

-- Business Purpose:
-- This query analyzes the adoption and characteristics of telehealth visits to help:
-- 1. Understand telehealth utilization patterns over time
-- 2. Compare telehealth vs in-person visit characteristics
-- 3. Identify which specialties are leveraging telehealth most effectively
-- 4. Support strategic planning for virtual care initiatives

WITH telehealth_metrics AS (
  -- Calculate core telehealth metrics by year and specialty
  SELECT 
    opdateyr as visit_year,
    drsplty as doctor_specialty,
    CASE WHEN telehealthflag = 1 THEN 'Telehealth' ELSE 'In-Person' END as visit_mode,
    COUNT(*) as visit_count,
    COUNT(DISTINCT dupersid) as unique_patients,
    AVG(CAST(opxp_yy_x AS FLOAT)) as avg_visit_cost,
    SUM(CASE WHEN medpresc = 1 THEN 1 ELSE 0 END) as rx_prescribed_visits
  FROM mimi_ws_1.ahrq.meps_event_outpatientvisits
  WHERE opdateyr >= 2019  -- Focus on COVID-19 and post-COVID periods
  GROUP BY opdateyr, drsplty, telehealthflag
),

visit_trends AS (
  -- Calculate year-over-year growth and penetration metrics
  SELECT 
    visit_year,
    doctor_specialty,
    visit_mode,
    visit_count,
    unique_patients,
    avg_visit_cost,
    rx_prescribed_visits,
    100.0 * visit_count / SUM(visit_count) OVER (PARTITION BY visit_year, doctor_specialty) as mode_penetration
  FROM telehealth_metrics
)

SELECT
  visit_year,
  doctor_specialty,
  visit_mode,
  visit_count,
  unique_patients,
  ROUND(avg_visit_cost, 2) as avg_visit_cost,
  rx_prescribed_visits,
  ROUND(mode_penetration, 1) as mode_penetration_pct,
  ROUND(100.0 * rx_prescribed_visits / visit_count, 1) as rx_rate_pct
FROM visit_trends
ORDER BY 
  visit_year,
  doctor_specialty,
  visit_mode;

-- How this query works:
-- 1. First CTE aggregates core metrics by year, specialty and visit mode
-- 2. Second CTE calculates penetration rates and related metrics
-- 3. Final SELECT formats and presents the results with key indicators

-- Assumptions and Limitations:
-- 1. Relies on accurate flagging of telehealth visits in source data
-- 2. Cost comparisons may not account for all telehealth-specific factors
-- 3. Limited to years where telehealth flag is present in the data
-- 4. Specialty classifications may vary over time

-- Possible Extensions:
-- 1. Add geographic analysis of telehealth adoption
-- 2. Include patient demographics and social determinants
-- 3. Analyze specific conditions treated via telehealth
-- 4. Compare quality metrics between telehealth and in-person visits
-- 5. Forecast future telehealth utilization trends

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:04:19.010416
    - Additional Notes: Query focuses on post-2019 data to capture COVID-19 impact on telehealth adoption. Requires telehealthflag column to be populated. Cost calculations assume consistent reporting methodology across telehealth and in-person visits.
    
    */