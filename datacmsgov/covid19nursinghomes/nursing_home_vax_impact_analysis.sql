-- nursing_home_staff_vaccination_impact.sql
-- Business Purpose: Analyze the relationship between staff vaccination rates and COVID-19 outcomes
-- This analysis helps healthcare organizations understand the ROI of vaccination programs
-- and make data-driven decisions about resource allocation for staff health initiatives

WITH staff_vax_metrics AS (
  SELECT 
    provider_state,
    provider_name,
    week_ending,
    number_of_all_healthcare_personnel_eligible_to_work_in_this_facility_for_at_least_1_day_this_week as total_staff,
    percentage_of_current_healthcare_personnel_up_to_date_with_covid19_vaccines as staff_vax_rate,
    staff_weekly_confirmed_covid19 as weekly_staff_cases,
    residents_weekly_confirmed_covid19 as weekly_resident_cases
  FROM mimi_ws_1.datacmsgov.covid19nursinghomes
  WHERE 
    week_ending >= '2023-01-01' -- Focus on recent data
    AND passed_quality_assurance_check = 'Y'
    AND submitted_data = 'Y'
)

SELECT
  provider_state,
  -- Create vaccination rate buckets
  CASE 
    WHEN staff_vax_rate >= 80 THEN 'High (80%+)'
    WHEN staff_vax_rate >= 60 THEN 'Medium (60-79%)'
    WHEN staff_vax_rate > 0 THEN 'Low (<60%)'
    ELSE 'No Data'
  END as vax_rate_category,
  
  -- Calculate key metrics
  COUNT(DISTINCT provider_name) as facility_count,
  ROUND(AVG(staff_vax_rate),1) as avg_staff_vax_rate,
  ROUND(AVG(weekly_staff_cases),2) as avg_weekly_staff_cases,
  ROUND(AVG(weekly_resident_cases),2) as avg_weekly_resident_cases,
  
  -- Calculate correlation between staff and resident cases
  ROUND(CORR(weekly_staff_cases, weekly_resident_cases),3) as staff_resident_case_correlation

FROM staff_vax_metrics
GROUP BY 1,2
HAVING facility_count > 5 -- Remove small sample sizes
ORDER BY 1,2;

-- How this works:
-- 1. Creates a CTE with core metrics filtered to recent data
-- 2. Categorizes facilities by vaccination rate ranges
-- 3. Calculates average cases and correlation metrics by state and category
-- 4. Filters out categories with too few facilities for statistical validity

-- Assumptions & Limitations:
-- - Requires reliable staff vaccination reporting
-- - Correlation doesn't imply causation
-- - Doesn't account for local COVID-19 prevalence
-- - Recent data may be affected by reporting delays

-- Possible Extensions:
-- 1. Add trend analysis over time periods
-- 2. Include facility size and occupancy rate analysis
-- 3. Add geographic clustering analysis
-- 4. Incorporate quality metrics and star ratings
-- 5. Calculate economic impact metrics
-- 6. Add staffing shortage correlation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:43:15.542289
    - Additional Notes: Query focuses on vaccination rate categories and their correlation with COVID-19 cases. Results are aggregated at state level and require minimum 5 facilities per category for statistical significance. Data is limited to post-2023 records with quality assurance checks passed.
    
    */