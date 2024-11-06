-- Title: Outpatient Visit Specialty and Provider Type Analysis

-- Business Purpose:
-- This query analyzes the distribution of outpatient visits across medical specialties
-- and provider types to help healthcare organizations:
-- 1. Understand provider workforce composition and utilization
-- 2. Identify potential gaps in specialty coverage
-- 3. Support capacity planning and provider recruitment strategies
-- 4. Track changes in care delivery patterns over time

WITH visit_metrics AS (
  -- Calculate visit counts by specialty and provider type
  SELECT 
    opdateyr AS visit_year,
    drsplty AS doctor_specialty,
    medptype AS provider_type,
    COUNT(*) AS visit_count,
    COUNT(DISTINCT dupersid) AS unique_patients,
    -- Calculate average visits per patient
    ROUND(COUNT(*)::FLOAT / COUNT(DISTINCT dupersid), 2) AS visits_per_patient,
    -- Calculate specialty share of total visits
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY opdateyr), 2) AS specialty_visit_share
  FROM mimi_ws_1.ahrq.meps_event_outpatientvisits
  WHERE opdateyr >= 2018  -- Focus on recent years
    AND drsplty IS NOT NULL  -- Exclude records missing specialty info
    AND medptype IS NOT NULL -- Exclude records missing provider type
  GROUP BY 
    opdateyr,
    drsplty,
    medptype
)

SELECT 
  visit_year,
  doctor_specialty,
  provider_type,
  visit_count,
  unique_patients,
  visits_per_patient,
  specialty_visit_share
FROM visit_metrics
WHERE visit_count >= 100  -- Filter to specialties with meaningful volume
ORDER BY 
  visit_year DESC,
  visit_count DESC;

-- How the Query Works:
-- 1. Creates a CTE to aggregate visit metrics by year, specialty, and provider type
-- 2. Calculates key utilization metrics including visit counts and patient counts
-- 3. Computes the percentage share of total visits for each specialty
-- 4. Filters results to focus on specialties with significant volume
-- 5. Orders results by year and visit volume for easy analysis

-- Assumptions and Limitations:
-- 1. Assumes specialty and provider type coding is consistent across years
-- 2. Limited to outpatient visits only - doesn't include other care settings
-- 3. Survey-based data may not perfectly represent all US healthcare delivery
-- 4. Filtering to visits >= 100 may exclude some rare specialties

-- Possible Extensions:
-- 1. Add geographic analysis by linking to patient location data
-- 2. Include procedure/service analysis by specialty
-- 3. Compare visit patterns between urban and rural areas
-- 4. Analyze seasonal variation in specialty utilization
-- 5. Add demographic breakdowns of patient populations by specialty

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:08:38.336986
    - Additional Notes: Note that this query focuses on high-volume specialties and provider types (>=100 visits) and requires 2018+ data to be present in the table. For analysis of rare specialties or historical trends before 2018, the visit_count filter and year filter should be adjusted accordingly.
    
    */