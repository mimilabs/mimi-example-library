-- Title: Healthcare Technology and Prevention Opportunity Analysis by ZIP Code

/* Business Purpose:
   Analyze the intersection of healthcare technology access, preventive health behaviors,
   and potential intervention opportunities across different ZIP codes.

   Key Objectives:
   1. Identify ZIP codes with low digital access and low preventive healthcare engagement
   2. Highlight potential digital health intervention strategies
   3. Provide insights for targeted community health programs and resource allocation
*/

WITH digital_health_assessment AS (
    SELECT 
        zipcode,
        state,
        -- Digital Access Metrics
        acs_pct_hh_no_comp_dev_zc AS no_computing_device_pct,
        acs_pct_hh_no_internet_zc AS no_internet_pct,
        
        -- Preventive Health Metrics
        cdcp_doctor_visit_adult_c_zc AS annual_checkup_pct,
        cdcp_dentist_visit_adult_c_zc AS dental_visit_pct,
        
        -- Health Screening Indicators
        cdcp_fobt_sig_col_50_75_c_zc AS cancer_screening_pct,
        cdcp_cervcan_scr_f21_65_c_zc AS cervical_screening_pct,
        
        -- Population Context
        acs_tot_civil_noninst_pop_zc AS total_population,
        acs_median_hh_inc_zc AS median_household_income
    FROM 
        mimi_ws_1.ahrq.sdohdb_zipcode
    WHERE 
        year = (SELECT MAX(year) FROM mimi_ws_1.ahrq.sdohdb_zipcode)
),

digital_health_risk_score AS (
    SELECT 
        zipcode,
        state,
        total_population,
        median_household_income,
        
        -- Composite Digital Health Risk Score
        ROUND(
            (no_computing_device_pct * 0.3) + 
            (no_internet_pct * 0.3) + 
            (100 - annual_checkup_pct * 0.2) + 
            (100 - cancer_screening_pct * 0.2),
            2
        ) AS digital_health_risk_score,
        
        no_computing_device_pct,
        no_internet_pct,
        annual_checkup_pct,
        cancer_screening_pct
    FROM 
        digital_health_assessment
)

SELECT 
    state,
    ROUND(AVG(digital_health_risk_score), 2) AS avg_state_digital_health_risk,
    ROUND(AVG(no_computing_device_pct), 2) AS avg_no_device_pct,
    ROUND(AVG(no_internet_pct), 2) AS avg_no_internet_pct,
    ROUND(AVG(annual_checkup_pct), 2) AS avg_annual_checkup_pct,
    ROUND(AVG(cancer_screening_pct), 2) AS avg_cancer_screening_pct,
    COUNT(*) AS num_zip_codes
FROM 
    digital_health_risk_score
GROUP BY 
    state
ORDER BY 
    avg_state_digital_health_risk DESC
LIMIT 20;

/* Query Explanation:
   1. Extracts key digital access and preventive health metrics from the most recent year
   2. Calculates a composite Digital Health Risk Score considering:
      - Lack of computing devices
      - Lack of internet access
      - Low annual checkup rates
      - Low cancer screening rates
   3. Aggregates results by state to identify systemic digital health challenges

   Assumptions and Limitations:
   - Uses most recent available year in the dataset
   - Risk score is a simplified, weighted metric
   - Assumes equal importance of different risk factors
   - Does not account for local healthcare infrastructure variations

   Potential Extensions:
   1. Add demographic segmentation (age, income groups)
   2. Include more detailed health screening metrics
   3. Develop predictive models for targeted interventions
   4. Compare urban vs rural digital health disparities
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:30:11.066585
    - Additional Notes: Calculates a composite digital health risk score by combining technology access and preventive healthcare metrics at the ZIP code and state level. Provides insights into potential digital health intervention strategies and areas of healthcare engagement challenges.
    
    */