-- analyze_top_hcpcs_codes_by_specialty.sql 

-- Business Purpose: Analyze which DME products/services (HCPCS codes) are most frequently ordered
-- by different provider specialties to identify key equipment needs and spending patterns across
-- specialties. This helps DME manufacturers, suppliers and healthcare organizations optimize 
-- inventory, pricing and contracting strategies.

WITH specialty_hcpcs_summary AS (
  -- Aggregate DME utilization metrics by specialty and HCPCS code
  SELECT 
    suplr_prvdr_spclty_desc,
    hcpcs_cd,
    hcpcs_desc,
    rbcs_lvl,
    COUNT(DISTINCT suplr_npi) as supplier_count,
    SUM(tot_suplr_srvcs) as total_services,
    SUM(tot_suplr_srvcs * avg_suplr_mdcr_alowd_amt) as total_allowed_amt
  FROM mimi_ws_1.datacmsgov.mupdme_suphpr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
    AND tot_suplr_srvcs >= 11 -- Filter out low volume records
    AND suplr_prvdr_spclty_desc IS NOT NULL
  GROUP BY 1,2,3,4
),

ranked_hcpcs AS (
  -- Rank HCPCS codes within each specialty by total allowed amount
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY suplr_prvdr_spclty_desc 
                       ORDER BY total_allowed_amt DESC) as rank_in_specialty
  FROM specialty_hcpcs_summary
)

-- Get top 5 HCPCS codes by allowed amount for each specialty
SELECT
  suplr_prvdr_spclty_desc as provider_specialty,
  hcpcs_cd,
  hcpcs_desc,
  rbcs_lvl as equipment_category,
  supplier_count,
  total_services,
  total_allowed_amt,
  ROUND(total_allowed_amt / total_services, 2) as avg_allowed_per_service
FROM ranked_hcpcs 
WHERE rank_in_specialty <= 5
ORDER BY provider_specialty, total_allowed_amt DESC;

-- How this query works:
-- 1. First CTE aggregates key DME metrics by provider specialty and HCPCS code
-- 2. Second CTE ranks HCPCS codes within each specialty based on total allowed amount
-- 3. Final query returns top 5 codes for each specialty with usage and spending metrics
-- 4. Results show which DME products are most important for different specialties

-- Assumptions and Limitations:
-- - Uses most recent full year of data (2022)
-- - Excludes records with fewer than 11 services for statistical validity
-- - Rankings based on total allowed amount - could use other metrics
-- - Limited to top 5 codes per specialty - adjust limit as needed
-- - Specialty must be non-null

-- Possible Extensions:
-- 1. Add year-over-year trending analysis
-- 2. Include geographic analysis by state/region
-- 3. Compare rental vs purchase patterns by specialty
-- 4. Add market share analysis for key suppliers
-- 5. Calculate specialty-specific cost per beneficiary metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:46:19.917263
    - Additional Notes: The query analyzes product utilization patterns across medical specialties, identifying the highest-value DME products per specialty based on Medicare allowed amounts. Best used for strategic inventory planning and specialty-specific market analysis. Note that results are filtered to specialties with sufficient volume (>11 services) which may exclude some niche providers.
    
    */