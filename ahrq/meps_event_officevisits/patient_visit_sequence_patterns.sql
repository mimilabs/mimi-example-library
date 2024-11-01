-- MEPS Office Visit Patient Journey Analysis 
-- Business Purpose: Analyze patient care pathways and visit patterns to:
-- 1. Understand the progression of care across visit types
-- 2. Identify key diagnostic and treatment sequences
-- 3. Support care coordination and continuity of care initiatives

WITH visit_sequence AS (
  SELECT 
    dupersid,
    obdateyr,
    obdatemm,
    evntidx,
    -- Capture key clinical activities
    CASE WHEN seedoc = 1 THEN 'MD Visit' 
         WHEN medptype IN (2,3) THEN 'Nurse/PA Visit'
         ELSE 'Other Provider' END AS provider_type,
    CASE WHEN labtest = 1 OR sonogram = 1 OR xrays = 1 OR mri = 1 
         THEN 1 ELSE 0 END AS had_diagnostics,
    CASE WHEN vstrelcn = 1 THEN 'Condition-Related'
         ELSE 'General Care' END AS visit_reason,
    medpresc AS rx_prescribed,
    -- Create visit sequence number per patient
    ROW_NUMBER() OVER (
      PARTITION BY dupersid 
      ORDER BY obdateyr, obdatemm, evntidx
    ) AS visit_sequence_num
  FROM mimi_ws_1.ahrq.meps_event_officevisits
  WHERE obdateyr >= 2020 -- Focus on recent years
)

SELECT
  visit_sequence_num,
  provider_type,
  COUNT(*) as visit_count,
  AVG(had_diagnostics)*100 as pct_with_diagnostics,
  SUM(CASE WHEN rx_prescribed = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*) as pct_with_rx,
  COUNT(DISTINCT dupersid) as unique_patients
FROM visit_sequence
GROUP BY 1, 2
ORDER BY visit_sequence_num, provider_type;

-- How this works:
-- 1. Creates visit sequences for each patient ordered by date
-- 2. Categorizes visits by provider type and key clinical activities
-- 3. Analyzes patterns across sequential visits
-- 4. Aggregates metrics to show progression of care

-- Assumptions and limitations:
-- - Requires chronological completeness of visit records
-- - May miss visits outside the system
-- - Sequential patterns may be affected by gaps in care
-- - Limited to available years in dataset

-- Possible extensions:
-- 1. Add time gaps between visits
-- 2. Include specialty-specific analysis
-- 3. Add condition codes to track specific disease pathways
-- 4. Incorporate telehealth vs in-person patterns
-- 5. Add cost progression analysis across visit sequence

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:44:00.789790
    - Additional Notes: Query tracks patient care progression by analyzing visit patterns and clinical activities across sequential visits. Best used for longitudinal care pathway analysis and identifying typical treatment sequences. Note that accuracy depends on completeness of visit records within the system.
    
    */