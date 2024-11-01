-- Generic vs Brand Drug Cost Impact Analysis in Medicare Part D

-- Business Purpose:
-- This query analyzes the cost differential between generic and brand-name prescriptions
-- across providers to identify opportunities for cost savings through generic utilization.
-- The analysis helps payers and policymakers understand prescribing patterns and potential
-- areas for intervention to promote cost-effective prescribing.

WITH prescriber_costs AS (
    -- Calculate total and per-claim costs for generic and brand drugs
    SELECT
        prscrbr_npi,
        prscrbr_last_org_name,
        prscrbr_type,
        prscrbr_state_abrvtn,
        
        -- Generic metrics
        gnrc_tot_clms,
        gnrc_tot_drug_cst,
        CASE 
            WHEN gnrc_tot_clms > 0 THEN gnrc_tot_drug_cst / gnrc_tot_clms 
            ELSE 0 
        END AS gnrc_cost_per_claim,
        
        -- Brand metrics  
        brnd_tot_clms,
        brnd_tot_drug_cst,
        CASE 
            WHEN brnd_tot_clms > 0 THEN brnd_tot_drug_cst / brnd_tot_clms 
            ELSE 0 
        END AS brnd_cost_per_claim,
        
        -- Overall generic utilization rate
        CASE 
            WHEN (gnrc_tot_clms + brnd_tot_clms) > 0 
            THEN ROUND(100.0 * gnrc_tot_clms / (gnrc_tot_clms + brnd_tot_clms), 1)
            ELSE 0 
        END AS generic_utilization_rate
        
    FROM mimi_ws_1.datacmsgov.mupdpr_prvdr
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
        AND gnrc_tot_clms > 0  -- Only include providers with generic claims
        AND brnd_tot_clms > 0  -- Only include providers with brand claims
)

SELECT 
    prscrbr_type,
    prscrbr_state_abrvtn,
    COUNT(DISTINCT prscrbr_npi) as provider_count,
    
    -- Aggregate cost metrics
    ROUND(AVG(generic_utilization_rate), 1) as avg_generic_rate,
    ROUND(AVG(gnrc_cost_per_claim), 2) as avg_generic_cost_per_claim,
    ROUND(AVG(brnd_cost_per_claim), 2) as avg_brand_cost_per_claim,
    ROUND(AVG(brnd_cost_per_claim - gnrc_cost_per_claim), 2) as avg_cost_difference_per_claim,
    
    -- Total volume and costs
    SUM(gnrc_tot_clms) as total_generic_claims,
    SUM(brnd_tot_clms) as total_brand_claims,
    ROUND(SUM(gnrc_tot_drug_cst), 2) as total_generic_cost,
    ROUND(SUM(brnd_tot_drug_cst), 2) as total_brand_cost
    
FROM prescriber_costs
GROUP BY prscrbr_type, prscrbr_state_abrvtn
HAVING COUNT(DISTINCT prscrbr_npi) >= 10  -- Ensure meaningful sample size
ORDER BY avg_cost_difference_per_claim DESC;

-- How this query works:
-- 1. Creates a CTE to calculate per-provider metrics for generic and brand prescriptions
-- 2. Includes only providers who prescribe both generic and brand drugs
-- 3. Calculates average costs per claim and generic utilization rates
-- 4. Aggregates results by provider type and state
-- 5. Filters for groups with sufficient sample size

-- Assumptions and Limitations:
-- 1. Uses most recent year of data (2022)
-- 2. Excludes providers with zero generic or brand claims
-- 3. Requires minimum of 10 providers per group for statistical relevance
-- 4. Does not account for differences in drug classes or therapeutic categories
-- 5. Cost differences may reflect legitimate clinical needs rather than inefficient prescribing

-- Possible Extensions:
-- 1. Add trending analysis across multiple years
-- 2. Include therapeutic category analysis
-- 3. Add beneficiary risk score correlation
-- 4. Compare against regional/national benchmarks
-- 5. Add provider specialty-specific generic prescribing targets
-- 6. Include analysis of Medicare Advantage vs Part D plan differences

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:07:57.481925
    - Additional Notes: Query requires providers to have both generic and brand claims in 2022, which may exclude specialists who primarily prescribe one type. Cost differentials should be interpreted alongside clinical appropriateness factors. Minimum group size of 10 providers may limit analysis in rural areas or specialized provider types.
    
    */