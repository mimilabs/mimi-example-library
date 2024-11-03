-- manufacturer_specialization_assessment.sql
-- 
-- Business Purpose:
-- Analyze manufacturer payment patterns to identify their specialization and market focus by examining:
-- - Which manufacturers concentrate payments in specific medical specialties
-- - Level of investment in each medical specialty
-- - Diversity of their payment portfolio
-- This helps with:
-- - Understanding competitive positioning in specialty markets
-- - Identifying niche vs. broad-market manufacturers
-- - Supporting market entry and partnership decisions

WITH manufacturer_specialty_summary AS (
  -- Calculate total payments by manufacturer and specialty
  SELECT 
    applicable_manufacturer_or_applicable_gpo_making_payment_name as manufacturer_name,
    covered_recipient_primary_type_1 as specialty,
    COUNT(DISTINCT covered_recipient_profile_id) as unique_recipients,
    SUM(total_amount_of_payment_us_dollars) as total_payments,
    SUM(total_amount_of_payment_us_dollars) / COUNT(DISTINCT covered_recipient_profile_id) as avg_payment_per_recipient
  FROM mimi_ws_1.openpayments.general
  WHERE program_year >= 2020
    AND covered_recipient_primary_type_1 IS NOT NULL
  GROUP BY 1, 2
),

manufacturer_metrics AS (
  -- Calculate key metrics per manufacturer
  SELECT 
    manufacturer_name,
    COUNT(DISTINCT specialty) as specialty_count,
    SUM(total_payments) as manufacturer_total_payments,
    MAX(total_payments) as highest_specialty_payment,
    MAX(total_payments) / NULLIF(SUM(total_payments), 0) * 100 as top_specialty_concentration_pct
  FROM manufacturer_specialty_summary
  GROUP BY 1
)

-- Final output combining key insights
SELECT 
  m.manufacturer_name,
  m.specialty_count,
  m.manufacturer_total_payments,
  m.top_specialty_concentration_pct,
  s.specialty as top_specialty,
  s.unique_recipients as top_specialty_recipients,
  s.avg_payment_per_recipient as top_specialty_avg_payment
FROM manufacturer_metrics m
JOIN manufacturer_specialty_summary s
  ON m.manufacturer_name = s.manufacturer_name
  AND m.highest_specialty_payment = s.total_payments
WHERE m.manufacturer_total_payments > 1000000
ORDER BY m.manufacturer_total_payments DESC
LIMIT 100;

-- How it works:
-- 1. First CTE aggregates payments by manufacturer and specialty to get base metrics
-- 2. Second CTE calculates manufacturer-level concentration metrics
-- 3. Final query joins these together to show top specialty focus for each major manufacturer
--
-- Assumptions & Limitations:
-- - Uses primary specialty only (doesn't account for secondary specialties)
-- - Focuses on recent data (2020+) for current relevance
-- - Excludes small manufacturers (<$1M total payments) to focus on major players
-- - Concentration % may be skewed for manufacturers with very small total payments
--
-- Possible Extensions:
-- 1. Add year-over-year specialty focus changes to identify strategic shifts
-- 2. Include product categories to link specialties with product lines
-- 3. Compare manufacturer specialty focus against market size/opportunity
-- 4. Add geographic analysis of specialty concentration
-- 5. Incorporate payment types to understand engagement methods by specialty

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:24:57.902538
    - Additional Notes: Query requires minimum of 2 years of data post-2020 for meaningful concentration metrics. Memory usage may be high for full dataset analysis due to multiple aggregations. Consider adding date range parameters for more flexible analysis periods.
    
    */