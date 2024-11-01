-- TITLE: Service Type Impact Analysis on Medicare MUE Values 
-- 
-- PURPOSE: Analyze how service types influence MUE values and identify potential 
-- cost management opportunities by comparing MUE values across service settings.
-- This analysis helps:
-- - Healthcare administrators optimize service location decisions
-- - Payers understand cost variations across settings
-- - Providers make informed decisions about service delivery locations
--

WITH ranked_procedures AS (
  -- Get the most significant procedures based on MUE values
  SELECT 
    hcpcs_cpt_code,
    service_type,
    COALESCE(dme_supplier_services_mue_values, 0) as dme_mue,
    COALESCE(practitioner_services_mue_values, 0) as prac_mue,
    COALESCE(outpatient_hospital_services_mue_values, 0) as hosp_mue,
    mue_rationale
  FROM mimi_ws_1.cmscoding.nicc_mue
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.cmscoding.nicc_mue)
    AND (dme_supplier_services_mue_values > 0 
    OR practitioner_services_mue_values > 0 
    OR outpatient_hospital_services_mue_values > 0)
)

SELECT 
  hcpcs_cpt_code,
  -- Calculate max MUE across settings
  GREATEST(dme_mue, prac_mue, hosp_mue) as max_mue,
  -- Calculate setting variation
  ABS(prac_mue - hosp_mue) as prac_hosp_variation,
  -- Flag significant variations
  CASE 
    WHEN ABS(prac_mue - hosp_mue) > 5 THEN 'High Variation'
    WHEN ABS(prac_mue - hosp_mue) > 0 THEN 'Some Variation'
    ELSE 'No Variation'
  END as variation_category,
  mue_rationale,
  -- Show values by setting
  dme_mue as dme_setting,
  prac_mue as practitioner_setting,
  hosp_mue as hospital_setting
FROM ranked_procedures
WHERE prac_mue > 0 OR hosp_mue > 0  -- Focus on settings with actual values
ORDER BY prac_hosp_variation DESC, max_mue DESC
LIMIT 100;

-- HOW IT WORKS:
-- 1. Creates CTE with latest MUE data and non-zero values
-- 2. Calculates variations between practitioner and hospital settings
-- 3. Categorizes variations to highlight significant differences
-- 4. Orders by variation magnitude and overall MUE values
--
-- ASSUMPTIONS & LIMITATIONS:
-- - Uses most recent data only
-- - Focuses on practitioner vs hospital comparison
-- - Limited to top 100 procedures
-- - Assumes non-zero values are meaningful
--
-- POSSIBLE EXTENSIONS:
-- 1. Add time-based trending of variations
-- 2. Include cost implications using procedure cost data
-- 3. Group by clinical categories or specialties
-- 4. Add statistical significance testing
-- 5. Include geographic variations if data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:13:03.963787
    - Additional Notes: Query focuses on analyzing MUE value variations across different service settings (DME, practitioner, hospital). Results are limited to top 100 procedures with the highest variations. Only considers the most recent data snapshot and requires at least one non-zero value between practitioner and hospital settings.
    
    */