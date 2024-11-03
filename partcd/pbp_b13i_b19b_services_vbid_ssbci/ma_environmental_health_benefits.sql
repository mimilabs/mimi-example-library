-- Medicare Advantage Indoor Air Quality and Pest Control Benefits Analysis

-- This query analyzes the adoption and coverage patterns of indoor air quality equipment/services
-- and pest control benefits across Medicare Advantage plans. These environmental health benefits
-- can significantly impact health outcomes for chronically ill beneficiaries, particularly those
-- with respiratory conditions or mobility limitations.

WITH benefit_summary AS (
  -- Get the most recent data for each plan
  SELECT DISTINCT
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    pbp_a_plan_type,
    
    -- Air quality benefit flags and coverage
    pbp_b13i_air_bendesc_yn AS offers_air_quality,
    pbp_b13i_air_maxplan_amt AS air_quality_max_amount,
    pbp_b13i_air_auth_yn AS air_quality_auth_required,
    
    -- Pest control benefit flags and coverage  
    pbp_b13i_ps_bendesc_yn AS offers_pest_control,
    pbp_b13i_ps_maxplan_amt AS pest_control_max_amount,
    pbp_b13i_ps_auth_yn AS pest_control_auth_required,
    
    mimi_src_file_date
  FROM mimi_ws_1.partcd.pbp_b13i_b19b_services_vbid_ssbci
  WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.partcd.pbp_b13i_b19b_services_vbid_ssbci
  )
)

SELECT
  -- Calculate overall adoption rates
  COUNT(DISTINCT pbp_a_hnumber || pbp_a_plan_identifier) as total_plans,
  
  SUM(CASE WHEN offers_air_quality = 'Y' THEN 1 ELSE 0 END) as plans_with_air_quality,
  ROUND(100.0 * SUM(CASE WHEN offers_air_quality = 'Y' THEN 1 ELSE 0 END) / 
    COUNT(DISTINCT pbp_a_hnumber || pbp_a_plan_identifier), 1) as pct_plans_air_quality,
    
  SUM(CASE WHEN offers_pest_control = 'Y' THEN 1 ELSE 0 END) as plans_with_pest_control,
  ROUND(100.0 * SUM(CASE WHEN offers_pest_control = 'Y' THEN 1 ELSE 0 END) / 
    COUNT(DISTINCT pbp_a_hnumber || pbp_a_plan_identifier), 1) as pct_plans_pest_control,
    
  -- Authorization requirements
  SUM(CASE WHEN offers_air_quality = 'Y' AND air_quality_auth_required = 'Y' THEN 1 ELSE 0 END) as air_quality_auth_required_count,
  SUM(CASE WHEN offers_pest_control = 'Y' AND pest_control_auth_required = 'Y' THEN 1 ELSE 0 END) as pest_control_auth_required_count,
  
  -- Average maximum coverage amounts for plans offering the benefits
  ROUND(AVG(CASE WHEN offers_air_quality = 'Y' THEN CAST(air_quality_max_amount AS FLOAT) ELSE NULL END), 0) as avg_air_quality_max_amount,
  ROUND(AVG(CASE WHEN offers_pest_control = 'Y' THEN CAST(pest_control_max_amount AS FLOAT) ELSE NULL END), 0) as avg_pest_control_max_amount

FROM benefit_summary

/*
How this query works:
- Creates a CTE with the most recent data for each plan
- Calculates adoption rates for air quality and pest control benefits
- Analyzes authorization requirements and coverage amounts
- Results show the prevalence and characteristics of these environmental health benefits

Assumptions and limitations:
- Uses most recent data snapshot only
- Assumes monetary amounts are stored as valid numbers
- Does not account for benefit variations within plan segments
- Does not analyze geographical distribution

Possible extensions:
1. Add geographical analysis by state/region
2. Compare adoption rates across different plan types
3. Analyze trends over time using historical data
4. Break down benefits by specific chronic conditions
5. Add analysis of other environmental health benefits
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:06:33.299745
    - Additional Notes: Query focuses specifically on air quality and pest control benefits, which are key environmental health interventions for Medicare Advantage beneficiaries with chronic conditions. Note that monetary coverage amounts may be null or zero in some records, which could affect average calculations.
    
    */