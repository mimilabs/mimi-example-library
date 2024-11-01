-- geographic_distribution_dme_spending.sql

-- Business Purpose: Analyze the geographic distribution of Medicare DME spending and utilization 
-- to identify regional variations, access patterns, and potential service gaps across
-- rural vs urban areas. This helps inform market expansion strategies and identify
-- underserved areas.

WITH total_regional_spending AS (
  -- Calculate total spending and services by RUCA category
  SELECT 
    suplr_prvdr_ruca_cat,
    suplr_prvdr_ruca_desc,
    COUNT(DISTINCT suplr_npi) as supplier_count,
    SUM(tot_suplr_srvcs) as total_services,
    SUM(tot_suplr_srvcs * avg_suplr_mdcr_alowd_amt) as total_allowed_amt,
    SUM(tot_suplr_benes) as total_beneficiaries
  FROM mimi_ws_1.datacmsgov.mupdme_suphpr
  WHERE mimi_src_file_date = '2022-12-31'
    AND suplr_prvdr_ruca_cat IS NOT NULL
    AND tot_suplr_benes >= 11  -- Exclude low volume for privacy
  GROUP BY 1,2
),

per_capita_metrics AS (
  -- Calculate per beneficiary metrics
  SELECT
    suplr_prvdr_ruca_cat,
    suplr_prvdr_ruca_desc,
    supplier_count,
    total_services,
    total_allowed_amt,
    total_beneficiaries,
    ROUND(total_allowed_amt / NULLIF(total_beneficiaries,0), 2) as allowed_amt_per_beneficiary,
    ROUND(total_services / NULLIF(total_beneficiaries,0), 2) as services_per_beneficiary,
    ROUND(total_beneficiaries / NULLIF(supplier_count,0), 2) as beneficiaries_per_supplier
  FROM total_regional_spending
)

SELECT * 
FROM per_capita_metrics
ORDER BY total_allowed_amt DESC;

-- How it works:
-- 1. First CTE aggregates key metrics by RUCA category (rural-urban classification)
-- 2. Second CTE calculates per capita ratios to normalize the metrics
-- 3. Final output provides a comparative view across geographic regions

-- Assumptions & Limitations:
-- - Uses 2022 data only - trends over time not captured
-- - Excludes records with <11 beneficiaries due to privacy rules
-- - RUCA categories must be populated (NULL values filtered out)
-- - Geographic analysis limited to RUCA categorization level

-- Possible Extensions:
-- 1. Add year-over-year comparison to identify changing patterns
-- 2. Break down by specific DME categories (rbcs_lvl) within regions
-- 3. Include state-level analysis alongside RUCA categories
-- 4. Add supplier specialty mix analysis by region
-- 5. Calculate market concentration metrics (e.g., HHI) by region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:23:06.368033
    - Additional Notes: Query provides standardized metrics for comparing DME access and utilization across rural and urban areas. Key metrics include per-beneficiary spending, service intensity, and supplier density. Results can help identify potential healthcare access disparities and guide resource allocation decisions.
    
    */