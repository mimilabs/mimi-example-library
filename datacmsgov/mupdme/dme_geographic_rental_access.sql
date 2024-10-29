-- DME Geographic Access and Rental Equipment Analysis
-- Business Purpose:
-- 1. Assess geographic distribution of DME services to identify potential access gaps
-- 2. Analyze rental vs purchase patterns for key equipment types
-- 3. Support strategic planning for DME supplier networks and rental programs
-- 4. Guide market expansion and network adequacy decisions

WITH rental_metrics AS (
    -- Calculate rental vs purchase metrics by region
    SELECT 
        rfrg_prvdr_state_abrvtn as state,
        rfrg_prvdr_ruca_cat as rural_urban_category,
        suplr_rentl_ind as is_rental,
        COUNT(DISTINCT rfrg_npi) as provider_count,
        SUM(tot_suplr_benes) as total_beneficiaries,
        SUM(tot_suplr_srvcs) as total_services,
        SUM(tot_suplr_srvcs * avg_suplr_mdcr_pymt_amt) as total_medicare_payments
    FROM mimi_ws_1.datacmsgov.mupdme
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    AND tot_suplr_benes >= 11  -- Exclude small volume for privacy
    GROUP BY 1,2,3
),

access_summary AS (
    -- Summarize access metrics by geography
    SELECT 
        state,
        rural_urban_category,
        SUM(CASE WHEN is_rental = 'Y' THEN total_beneficiaries ELSE 0 END) as rental_beneficiaries,
        SUM(CASE WHEN is_rental = 'N' THEN total_beneficiaries ELSE 0 END) as purchase_beneficiaries,
        SUM(CASE WHEN is_rental = 'Y' THEN total_medicare_payments ELSE 0 END) as rental_payments,
        SUM(CASE WHEN is_rental = 'N' THEN total_medicare_payments ELSE 0 END) as purchase_payments
    FROM rental_metrics
    GROUP BY 1,2
)

SELECT 
    state,
    rural_urban_category,
    rental_beneficiaries,
    purchase_beneficiaries,
    rental_payments,
    purchase_payments,
    ROUND(rental_beneficiaries::FLOAT / NULLIF((rental_beneficiaries + purchase_beneficiaries),0) * 100,1) as pct_rental_beneficiaries,
    ROUND(rental_payments::FLOAT / NULLIF((rental_payments + purchase_payments),0) * 100,1) as pct_rental_spend
FROM access_summary
WHERE state NOT IN ('ZZ','XX')  -- Exclude non-US locations
ORDER BY state, rural_urban_category;

-- How it works:
-- 1. First CTE aggregates basic rental vs purchase metrics by state and rural/urban category
-- 2. Second CTE calculates beneficiary counts and payment amounts for rentals vs purchases
-- 3. Final query computes percentages and formats results for analysis

-- Assumptions & Limitations:
-- 1. Uses most recent year of data (2022)
-- 2. Excludes records with <11 beneficiaries due to privacy rules
-- 3. Focus on state-level patterns may miss local market nuances
-- 4. Does not account for differences in equipment types or medical conditions

-- Possible Extensions:
-- 1. Add trending over multiple years
-- 2. Break out by specific equipment categories (HCPCS groups)
-- 3. Compare against demographic data to identify underserved populations
-- 4. Add supplier density metrics by geography
-- 5. Include cost per beneficiary calculations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:42:59.759607
    - Additional Notes: Query focuses on geographic patterns of DME rental vs purchase across rural/urban areas. Useful for network planning and access monitoring. Requires at least one year of data with sufficient beneficiary volumes (>11) to avoid privacy suppressions. Payment calculations assume consistent reimbursement policies across regions.
    
    */