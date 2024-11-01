-- SNF Emergency Preparedness Assessment
-- ===============================================

-- Business Purpose:
-- ----------------
-- This query analyzes emergency preparedness and disaster response capabilities
-- of Skilled Nursing Facilities by examining their:
-- - Emergency power systems and backup generators
-- - Disaster response protocols
-- - Emergency staffing arrangements
-- - Special care unit designations
-- This information is critical for:
-- 1. Risk assessment and mitigation planning
-- 2. Regulatory compliance evaluation
-- 3. Emergency response coordination with local authorities
-- 4. Resource allocation during disasters

WITH latest_reports AS (
  -- Get the most recent report for each facility
  SELECT 
    rpt_rec_num,
    MAX(mimi_src_file_date) as latest_date
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
  GROUP BY rpt_rec_num
),

facility_base AS (
  -- Extract facility identifiers and names
  SELECT DISTINCT
    a.rpt_rec_num,
    MAX(CASE WHEN a.wksht_cd = 'S200001' AND a.line_num = '1' AND a.clmn_num = '1' 
        THEN a.itm_alphnmrc_itm_txt END) as facility_name,
    MAX(CASE WHEN a.wksht_cd = 'S200001' AND a.line_num = '1' AND a.clmn_num = '2' 
        THEN a.itm_alphnmrc_itm_txt END) as provider_number
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha a
  JOIN latest_reports lr ON a.rpt_rec_num = lr.rpt_rec_num 
    AND a.mimi_src_file_date = lr.latest_date
  GROUP BY a.rpt_rec_num
),

emergency_prep AS (
  -- Collect emergency preparedness information
  SELECT 
    a.rpt_rec_num,
    MAX(CASE WHEN a.wksht_cd = 'S000001' AND a.line_num = '15' 
        THEN a.itm_alphnmrc_itm_txt END) as emergency_power_status,
    MAX(CASE WHEN a.wksht_cd = 'S000001' AND a.line_num = '16' 
        THEN a.itm_alphnmrc_itm_txt END) as disaster_plan_status,
    MAX(CASE WHEN a.wksht_cd = 'S000001' AND a.line_num = '17' 
        THEN a.itm_alphnmrc_itm_txt END) as special_care_unit_status
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha a
  JOIN latest_reports lr ON a.rpt_rec_num = lr.rpt_rec_num 
    AND a.mimi_src_file_date = lr.latest_date
  GROUP BY a.rpt_rec_num
)

-- Combine and analyze emergency preparedness metrics
SELECT 
  f.facility_name,
  f.provider_number,
  ep.emergency_power_status,
  ep.disaster_plan_status,
  ep.special_care_unit_status,
  CASE 
    WHEN ep.emergency_power_status IS NOT NULL 
      AND ep.disaster_plan_status IS NOT NULL 
      AND ep.special_care_unit_status IS NOT NULL 
    THEN 'Complete'
    ELSE 'Incomplete'
  END as preparedness_status
FROM facility_base f
LEFT JOIN emergency_prep ep ON f.rpt_rec_num = ep.rpt_rec_num
ORDER BY f.facility_name;

-- Query Operation:
-- ---------------
-- 1. Identifies most recent cost reports for each facility
-- 2. Extracts basic facility identification information
-- 3. Collects emergency preparedness indicators
-- 4. Combines information to create a preparedness assessment profile

-- Assumptions and Limitations:
-- --------------------------
-- 1. Assumes emergency preparedness information is reported in specified worksheets
-- 2. Limited to information available in cost reports
-- 3. May not capture real-time emergency preparedness status
-- 4. Relies on accurate self-reporting by facilities

-- Possible Extensions:
-- ------------------
-- 1. Add geographic analysis to assess regional preparedness levels
-- 2. Include historical trending of preparedness metrics
-- 3. Incorporate additional emergency-related facility features
-- 4. Add correlation analysis with facility size and patient population
-- 5. Include cost analysis of emergency preparedness investments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:16:39.213988
    - Additional Notes: This query focuses specifically on emergency preparedness status from worksheet S000001. Results may be limited based on data completeness in the emergency preparedness sections of the cost reports. Consider cross-referencing with state-level emergency preparedness requirements for full compliance assessment.
    
    */