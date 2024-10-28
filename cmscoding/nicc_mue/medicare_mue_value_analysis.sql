
/*******************************************************************************
TITLE: Basic Analysis of Medicare NCCI MUE Values and Patterns
 
PURPOSE: This query analyzes the Medicare National Correct Coding Initiative (NCCI)
Medically Unlikely Edit (MUE) values across different service types to identify:
- Most common procedures with high MUE limits
- Distribution of MUE values across service types
- Key rationales for MUE assignments

BUSINESS VALUE: 
- Helps healthcare providers understand billing limits for common procedures
- Identifies procedures that merit special attention in billing
- Provides insights into CMS's rationale for service limitations
*******************************************************************************/

WITH service_summary AS (
  -- Get the latest data for each code by using the most recent file date
  SELECT 
    hcpcs_cpt_code,
    dme_supplier_services_mue_values,
    practitioner_services_mue_values,
    outpatient_hospital_services_mue_values,
    mue_rationale,
    mimi_src_file_date
  FROM mimi_ws_1.cmscoding.nicc_mue
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.cmscoding.nicc_mue)
)

SELECT 
  -- Main analysis section
  hcpcs_cpt_code,
  mue_rationale,
  COALESCE(dme_supplier_services_mue_values, 0) as dme_mue,
  COALESCE(practitioner_services_mue_values, 0) as practitioner_mue,
  COALESCE(outpatient_hospital_services_mue_values, 0) as hospital_mue,
  -- Calculate the maximum MUE value across all service types
  GREATEST(
    COALESCE(dme_supplier_services_mue_values, 0),
    COALESCE(practitioner_services_mue_values, 0),
    COALESCE(outpatient_hospital_services_mue_values, 0)
  ) as max_mue_value
FROM service_summary
-- Focus on codes with significant MUE values
WHERE GREATEST(
    COALESCE(dme_supplier_services_mue_values, 0),
    COALESCE(practitioner_services_mue_values, 0),
    COALESCE(outpatient_hospital_services_mue_values, 0)
  ) > 0
ORDER BY max_mue_value DESC
LIMIT 100;

/*******************************************************************************
HOW IT WORKS:
1. Creates a CTE to get the most recent data snapshot
2. Analyzes MUE values across all service types
3. Calculates maximum MUE value for each code
4. Orders results by highest MUE values
5. Limits to top 100 most significant procedures

ASSUMPTIONS & LIMITATIONS:
- Uses most recent data only
- Treats null MUE values as 0
- Focuses only on procedures with non-zero MUE values
- Limited to top 100 results

POSSIBLE EXTENSIONS:
1. Add trend analysis by comparing MUE values across different file dates
2. Include analysis of adjudication indicators
3. Group results by mue_rationale to identify patterns
4. Add filtering by specific HCPCS/CPT code ranges
5. Include statistical analysis (avg, median, std dev) of MUE values
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:33:01.668104
    - Additional Notes: The query focuses on the most recent MUE values and their distribution across service types. Note that the GREATEST function assumes numeric MUE values and the query may need adjustment if any text values are present in the MUE columns. Consider adding date range parameters if historical analysis is needed.
    
    */