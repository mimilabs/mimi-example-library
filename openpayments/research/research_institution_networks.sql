-- institute_research_networks.sql

-- BUSINESS PURPOSE:
-- Analyze research networks and collaboration patterns between institutions (teaching hospitals)
-- and manufacturers. This helps identify key research hubs, strategic partnerships, and 
-- institutional centers of excellence. Understanding these networks provides insights into:
-- - Research concentration across healthcare institutions
-- - Manufacturer partnership strategies
-- - Geographic distribution of research activities

-- Main Query
WITH institution_research_summary AS (
  -- Aggregate research payments at the institution level
  SELECT 
    teaching_hospital_name,
    teaching_hospital_ccn,
    recipient_state,
    submitting_applicable_manufacturer_or_applicable_gpo_name as manufacturer_name,
    COUNT(DISTINCT record_id) as num_research_projects,
    COUNT(DISTINCT name_of_study) as unique_studies,
    SUM(total_amount_of_payment_us_dollars) as total_research_funding,
    COUNT(DISTINCT clinical_trials_gov_identifier) as num_clinical_trials
  FROM mimi_ws_1.openpayments.research
  WHERE teaching_hospital_name IS NOT NULL
    AND total_amount_of_payment_us_dollars > 0
  GROUP BY 1,2,3,4
),
ranked_partnerships AS (
  -- Identify top research partnerships
  SELECT 
    teaching_hospital_name,
    recipient_state,
    manufacturer_name,
    num_research_projects,
    total_research_funding,
    num_clinical_trials,
    ROW_NUMBER() OVER (PARTITION BY teaching_hospital_name 
                       ORDER BY total_research_funding DESC) as mfr_rank
  FROM institution_research_summary
)

SELECT
  teaching_hospital_name,
  recipient_state,
  COUNT(DISTINCT manufacturer_name) as num_research_partners,
  SUM(CASE WHEN mfr_rank = 1 THEN total_research_funding END) as top_partner_funding,
  MAX(CASE WHEN mfr_rank = 1 THEN manufacturer_name END) as top_research_partner,
  SUM(total_research_funding) as total_institution_funding,
  SUM(num_clinical_trials) as total_clinical_trials,
  ROUND(SUM(CASE WHEN mfr_rank = 1 THEN total_research_funding END) / 
        SUM(total_research_funding) * 100, 1) as top_partner_concentration_pct
FROM ranked_partnerships
GROUP BY 1,2
HAVING total_institution_funding > 1000000
ORDER BY total_institution_funding DESC
LIMIT 100;

-- HOW IT WORKS:
-- 1. First CTE aggregates research payment data at the institution-manufacturer level
-- 2. Second CTE ranks manufacturers by funding amount for each institution
-- 3. Final query summarizes institution research profiles including:
--    - Number of research partnerships
--    - Funding concentration with top partner
--    - Total research investment
--    - Clinical trial volume

-- ASSUMPTIONS & LIMITATIONS:
-- - Focuses only on teaching hospitals (excludes other research institutions)
-- - Assumes research payments accurately reflect partnership strength
-- - Limited to direct financial relationships captured in Open Payments
-- - May not capture full scope of multi-site or international research

-- POSSIBLE EXTENSIONS:
-- 1. Add geographic clustering analysis to identify research corridors
-- 2. Include therapeutic area focus for each institution
-- 3. Analyze temporal trends in partnership stability
-- 4. Add research type breakdown (preclinical vs clinical)
-- 5. Incorporate principal investigator network analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:30:58.382978
    - Additional Notes: Query focuses on bilateral relationships between teaching hospitals and manufacturers. The $1M funding threshold in the HAVING clause may need adjustment based on specific analysis needs. Consider caching or materializing the CTEs if running against large datasets as the window functions may be computationally intensive.
    
    */