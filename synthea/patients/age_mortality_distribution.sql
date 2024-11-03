-- Healthcare Demographics vs Preventive Care Status
-- =================================================
--
-- Business Purpose: 
-- This analysis identifies age-based population segments and living status
-- to help healthcare organizations optimize their preventive care programs
-- and resource allocation. By understanding the age distribution and mortality
-- patterns, organizations can better target preventive services and
-- outreach programs.

WITH patient_ages AS (
  SELECT 
    -- Create meaningful age segments
    CASE 
      WHEN DATEDIFF(CURRENT_DATE(), birthdate)/365 < 18 THEN 'Under 18'
      WHEN DATEDIFF(CURRENT_DATE(), birthdate)/365 BETWEEN 18 AND 30 THEN '18-30'
      WHEN DATEDIFF(CURRENT_DATE(), birthdate)/365 BETWEEN 31 AND 50 THEN '31-50'
      WHEN DATEDIFF(CURRENT_DATE(), birthdate)/365 BETWEEN 51 AND 70 THEN '51-70'
      ELSE 'Over 70'
    END AS age_group,
    
    -- Determine living status
    CASE WHEN deathdate IS NULL THEN 'Living' ELSE 'Deceased' END AS living_status
    
  FROM mimi_ws_1.synthea.patients
)

SELECT 
  age_group,
  living_status,
  COUNT(*) as patient_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY age_group), 1) as pct_in_age_group
FROM patient_ages
GROUP BY age_group, living_status
ORDER BY 
  CASE age_group
    WHEN 'Under 18' THEN 1
    WHEN '18-30' THEN 2
    WHEN '31-50' THEN 3
    WHEN '51-70' THEN 4
    WHEN 'Over 70' THEN 5
  END,
  living_status DESC;

-- How it works:
-- 1. Creates age groups based on current age calculation in a CTE
-- 2. Determines living vs deceased status
-- 3. Groups and aggregates the data
-- 4. Calculates percentages within each age group using window functions
-- 5. Orders results in a logical sequence

-- Assumptions and Limitations:
-- - Assumes birthdate is always populated
-- - Current date is used for age calculations
-- - Age groups are fixed and may need adjustment for specific use cases
-- - Synthetic data may not perfectly reflect real-world mortality patterns

-- Possible Extensions:
-- 1. Add gender distribution within age groups
-- 2. Include average healthcare expenses by age group
-- 3. Add year-over-year trend analysis
-- 4. Incorporate geographic factors for regional analysis
-- 5. Add risk scoring based on age and mortality patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:58:23.952252
    - Additional Notes: Query provides population health insights by combining age demographics with mortality status. The percentage calculations are particularly useful for identifying age groups with higher mortality rates, which can inform preventive care strategies. The age group boundaries (18, 30, 50, 70) are preset but may need adjustment based on specific healthcare program requirements.
    
    */