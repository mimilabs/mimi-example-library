-- dme_access_disparities.sql

-- Business Purpose:
-- - Identify geographic disparities in Medicare DME provider access and availability
-- - Support strategic planning for expanding DME provider networks
-- - Help detect areas that may need additional supplier coverage
-- - Enable population health management decisions around DME accessibility

WITH state_metrics AS (
    SELECT 
        rfrg_prvdr_geo_desc AS state,
        -- Calculate key access metrics per state
        SUM(tot_rfrg_prvdrs) AS total_referring_providers,
        SUM(tot_suplrs) AS total_suppliers,
        SUM(tot_suplr_benes) AS total_beneficiaries,
        -- Calculate ratios to assess access
        ROUND(SUM(tot_suplr_benes) / NULLIF(SUM(tot_suplrs), 0), 2) AS benes_per_supplier,
        ROUND(SUM(tot_suplr_benes) / NULLIF(SUM(tot_rfrg_prvdrs), 0), 2) AS benes_per_provider
    FROM mimi_ws_1.datacmsgov.mupdme_geo
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent full year
    AND rfrg_prvdr_geo_lvl = 'State'  -- State-level analysis
    GROUP BY rfrg_prvdr_geo_desc
)

SELECT 
    state,
    total_referring_providers,
    total_suppliers,
    total_beneficiaries,
    benes_per_supplier,
    benes_per_provider,
    -- Calculate percentile ranks to identify outliers
    PERCENT_RANK() OVER (ORDER BY benes_per_supplier) AS supplier_access_percentile,
    PERCENT_RANK() OVER (ORDER BY benes_per_provider) AS provider_access_percentile
FROM state_metrics
WHERE state NOT IN ('Foreign Country', 'Unknown')
ORDER BY benes_per_supplier DESC
LIMIT 20;

-- How it works:
-- 1. Aggregates key provider and supplier metrics at the state level
-- 2. Calculates beneficiary-to-provider ratios as access indicators
-- 3. Uses window functions to identify states with potential access challenges
-- 4. Filters out non-US geographies and ranks results

-- Assumptions and limitations:
-- - Uses most recent full year of data (2022)
-- - Does not account for population density or demographic differences
-- - Assumes even distribution of DME needs across beneficiary populations
-- - May not capture all access barriers (e.g., transportation, rural vs urban)

-- Possible extensions:
-- 1. Add trending analysis to show changes in access metrics over time
-- 2. Break down by equipment category to identify specific supply gaps
-- 3. Incorporate demographic data to assess equity considerations
-- 4. Add geographic clustering analysis to identify regional patterns
-- 5. Compare against quality metrics or outcomes data
-- 6. Create risk scores for areas with potential access challenges

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:31:22.938891
    - Additional Notes: Query focuses on provider-to-beneficiary ratios and may need adjustment for states with small populations where ratios could be skewed. Consider adding minimum thresholds for total_beneficiaries when using for policy decisions. Percentile calculations exclude territories but may need refinement based on specific regional analysis needs.
    
    */