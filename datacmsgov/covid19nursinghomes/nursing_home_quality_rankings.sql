-- nursing_home_quality_comparison.sql
-- Business Purpose: Analyze nursing home quality measures based on COVID-19 response
-- This analysis helps identify high and low performing facilities to:
-- 1. Share best practices from top performers
-- 2. Target support to struggling facilities
-- 3. Guide patient/family decisions about facility selection

WITH quality_metrics AS (
  -- Calculate key quality indicators by facility
  SELECT 
    provider_name,
    provider_state,
    county,
    number_of_all_beds,
    ROUND(AVG(total_number_of_occupied_beds/number_of_all_beds * 100), 1) as avg_occupancy_rate,
    ROUND(AVG(CAST(residents_weekly_confirmed_covid19 AS FLOAT)/NULLIF(total_number_of_occupied_beds, 0) * 1000), 2) as avg_weekly_case_rate,
    ROUND(AVG(CAST(recent_percentage_of_current_residents_up_to_date_with_covid19_vaccines AS FLOAT)), 1) as avg_resident_vax_rate,
    ROUND(AVG(CAST(recent_percentage_of_current_healthcare_personnel_up_to_date_with_covid19_vaccines AS FLOAT)), 1) as avg_staff_vax_rate,
    COUNT(DISTINCT week_ending) as weeks_reported
  FROM mimi_ws_1.datacmsgov.covid19nursinghomes
  WHERE 
    passed_quality_assurance_check = 'Y'
    AND week_ending >= '2023-01-01'
  GROUP BY 1,2,3,4
),
rankings AS (
  -- Create composite score and rankings
  SELECT 
    *,
    (COALESCE(avg_resident_vax_rate,0) + COALESCE(avg_staff_vax_rate,0))/2 - COALESCE(avg_weekly_case_rate,0) as composite_score,
    ROW_NUMBER() OVER (PARTITION BY provider_state ORDER BY 
      (COALESCE(avg_resident_vax_rate,0) + COALESCE(avg_staff_vax_rate,0))/2 - COALESCE(avg_weekly_case_rate,0) DESC) as state_rank
  FROM quality_metrics
  WHERE weeks_reported >= 26 -- At least 6 months of reporting
)

SELECT
  provider_name,
  provider_state,
  county,
  number_of_all_beds,
  avg_occupancy_rate,
  avg_weekly_case_rate,
  avg_resident_vax_rate,
  avg_staff_vax_rate,
  composite_score,
  state_rank,
  CASE 
    WHEN state_rank <= 5 THEN 'Top 5 in State'
    WHEN state_rank <= 10 THEN 'Top 6-10 in State'
    ELSE 'Other'
  END as performance_tier
FROM rankings
WHERE state_rank <= 10
ORDER BY provider_state, state_rank;

-- How it works:
-- 1. First CTE calculates key quality metrics per facility using 2023+ data
-- 2. Second CTE creates a composite score and state-level rankings
-- 3. Final query returns top 10 facilities per state with performance tiers

-- Assumptions & Limitations:
-- 1. Only includes facilities with consistent reporting (26+ weeks)
-- 2. Composite score weighs vaccination rates positively and case rates negatively
-- 3. Rankings are state-specific to account for regional variations
-- 4. Data quality relies on accurate facility reporting

-- Possible Extensions:
-- 1. Add trend analysis to show improvement/decline over time
-- 2. Include facility size and ownership type in analysis
-- 3. Create peer groups based on facility characteristics
-- 4. Add economic and demographic factors from external sources
-- 5. Calculate statistical significance of performance differences

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:22:37.430438
    - Additional Notes: Query focuses on creating state-level rankings of nursing homes based on composite quality scores derived from COVID-19 data. Filters for facilities with at least 6 months of consistent reporting in 2023+ to ensure reliable comparisons. Rankings consider both vaccination rates and case rates, with separate tiers for top performers in each state.
    
    */