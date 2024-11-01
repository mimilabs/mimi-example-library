-- DME Provider Prescribing Patterns and Cost Efficiency Analysis
-- 
-- Business Purpose:
-- 1. Identify the most prescribed DME items and their cost efficiency metrics
-- 2. Support contract negotiations with DME suppliers by understanding pricing variations
-- 3. Guide value-based care initiatives by highlighting cost-effective prescribing patterns
--

WITH provider_prescribing AS (
    -- Get the latest year's data and calculate total costs
    SELECT 
        hcpcs_cd,
        hcpcs_desc,
        rbcs_lvl,
        COUNT(DISTINCT rfrg_npi) as unique_prescribers,
        SUM(tot_suplr_srvcs) as total_services,
        SUM(tot_suplr_srvcs * avg_suplr_sbmtd_chrg) as total_submitted_charges,
        SUM(tot_suplr_srvcs * avg_suplr_mdcr_alowd_amt) as total_allowed_amount,
        SUM(tot_suplr_srvcs * avg_suplr_mdcr_pymt_amt) as total_medicare_paid
    FROM mimi_ws_1.datacmsgov.mupdme
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    GROUP BY 1,2,3
)

SELECT 
    hcpcs_cd,
    hcpcs_desc,
    rbcs_lvl,
    unique_prescribers,
    total_services,
    total_submitted_charges,
    total_allowed_amount,
    total_medicare_paid,
    -- Calculate key efficiency metrics
    ROUND(total_allowed_amount / total_services, 2) as avg_allowed_per_service,
    ROUND((total_submitted_charges - total_allowed_amount) / total_submitted_charges * 100, 1) as discount_percentage,
    ROUND(total_services / unique_prescribers, 1) as avg_services_per_prescriber
FROM provider_prescribing
WHERE total_services > 1000  -- Focus on commonly prescribed items
ORDER BY total_medicare_paid DESC
LIMIT 20;

-- How this query works:
-- 1. Aggregates DME utilization and cost data at the HCPCS code level
-- 2. Calculates key metrics including average cost per service and discount rates
-- 3. Focuses on frequently prescribed items with meaningful sample sizes
-- 4. Provides insights into cost variation and prescribing patterns

-- Assumptions and limitations:
-- 1. Uses most recent year's data only
-- 2. Excludes low-volume items (less than 1000 services)
-- 3. Averages may mask significant regional variations
-- 4. Does not account for clinical appropriateness or outcomes

-- Possible extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include regional price variation analysis
-- 3. Segment by provider specialty to identify specialty-specific patterns
-- 4. Add quality metrics when available
-- 5. Compare rental vs. purchase patterns for applicable items

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:19:42.129088
    - Additional Notes: Query focuses on item-level cost efficiency metrics across providers, requiring at least 1000 services per item to ensure statistical relevance. The discount_percentage metric helps identify items with the largest gaps between submitted and allowed charges, which can be valuable for cost containment efforts.
    
    */