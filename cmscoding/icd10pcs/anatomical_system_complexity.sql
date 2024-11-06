-- anatomical_systems_procedure_complexity.sql

-- Business Purpose: Analyze procedure complexity and distribution across anatomical systems
-- This analysis helps healthcare organizations:
-- 1. Understand their surgical capability requirements
-- 2. Plan resource allocation across different body systems
-- 3. Identify opportunities for specialization or expansion
-- 4. Support strategic planning for equipment and staffing needs

-- Main Query
WITH anatomical_systems AS (
  SELECT 
    -- First character of ICD-10-PCS code indicates body system
    LEFT(code, 1) as body_system,
    -- Character positions help determine procedure complexity
    LENGTH(TRIM(code)) as code_length,
    code,
    description,
    mimi_src_file_date
  FROM mimi_ws_1.cmscoding.icd10pcs
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.cmscoding.icd10pcs)
),

body_system_mapping AS (
  SELECT 
    body_system,
    CASE 
      WHEN body_system = '0' THEN 'Central Nervous System'
      WHEN body_system = '1' THEN 'Peripheral Nervous System'
      WHEN body_system = '2' THEN 'Heart and Great Vessels'
      WHEN body_system = '3' THEN 'Upper Arteries'
      WHEN body_system = '4' THEN 'Lower Arteries'
      WHEN body_system = '5' THEN 'Upper Veins'
      WHEN body_system = '6' THEN 'Lower Veins'
      WHEN body_system = '7' THEN 'Lymphatic and Hemic Systems'
      WHEN body_system = '8' THEN 'Eye'
      WHEN body_system = '9' THEN 'Ear, Nose, Sinus'
      WHEN body_system = 'B' THEN 'Respiratory System'
      WHEN body_system = 'C' THEN 'Mouth and Throat'
      WHEN body_system = 'D' THEN 'Gastrointestinal System'
      WHEN body_system = 'F' THEN 'Hepatobiliary System and Pancreas'
      ELSE 'Other Systems'
    END as system_name,
    COUNT(*) as procedure_count,
    AVG(code_length) as avg_complexity_score,
    MIN(description) as sample_procedure
  FROM anatomical_systems
  GROUP BY body_system
)

SELECT 
  system_name,
  procedure_count,
  ROUND(avg_complexity_score, 2) as complexity_score,
  sample_procedure
FROM body_system_mapping
WHERE system_name != 'Other Systems'
ORDER BY procedure_count DESC;

-- How it works:
-- 1. First CTE extracts body system from first character of ICD code
-- 2. Second CTE maps numeric/alpha codes to readable system names
-- 3. Final query presents results ordered by procedure volume
-- 4. Complexity score uses code length as a simple proxy for procedure complexity

-- Assumptions and Limitations:
-- 1. Uses latest available data only
-- 2. Code length as complexity proxy is simplified
-- 3. Not all body systems are mapped
-- 4. Sample procedure is arbitrary (first alphabetically)

-- Possible Extensions:
-- 1. Add trend analysis across multiple years
-- 2. Include procedure approach (minimally invasive vs. open)
-- 3. Cross-reference with specialty requirements
-- 4. Add procedure risk levels based on additional criteria
-- 5. Develop specialty-specific sub-analyses

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:26:53.392690
    - Additional Notes: Query provides high-level strategic view of procedure distribution and complexity across major body systems. Useful for healthcare facility planning, but complexity scoring is simplified and should not be used as sole decision factor. Consider local facility capabilities and specialties when interpreting results.
    
    */