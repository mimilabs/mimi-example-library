-- dmepos_medical_spend_categories.sql

-- Business Purpose: 
-- This query analyzes Medicare DMEPOS suppliers' spending patterns across major categories
-- (DME, Prosthetics/Orthotics, and Drugs/Nutritionals) to understand the distribution
-- of medical supply costs. This helps identify suppliers' specialization patterns and
-- supports strategic planning for Medicare cost management.

WITH supplier_totals AS (
    SELECT 
        -- Key supplier info
        suplr_prvdr_last_name_org,
        suplr_prvdr_state_abrvtn,
        
        -- Calculate total spend by category
        SUM(dme_suplr_mdcr_pymt_amt) as dme_total_spend,
        SUM(pos_suplr_mdcr_pymt_amt) as pos_total_spend,
        SUM(drug_suplr_mdcr_pymt_amt) as drug_total_spend,
        
        -- Calculate total Medicare payments across all categories
        SUM(suplr_mdcr_pymt_amt) as total_medicare_spend,
        
        -- Get beneficiary count for context
        SUM(tot_suplr_benes) as total_beneficiaries

    FROM mimi_ws_1.datacmsgov.mupdme_sup
    WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
    GROUP BY 1,2
    HAVING total_medicare_spend > 100000 -- Focus on significant suppliers
)

SELECT
    suplr_prvdr_state_abrvtn as state,
    
    -- Aggregate state-level category percentages
    ROUND(AVG(dme_total_spend/total_medicare_spend * 100),1) as avg_dme_pct,
    ROUND(AVG(pos_total_spend/total_medicare_spend * 100),1) as avg_pos_pct,
    ROUND(AVG(drug_total_spend/total_medicare_spend * 100),1) as avg_drug_pct,
    
    -- State totals
    COUNT(DISTINCT suplr_prvdr_last_name_org) as supplier_count,
    SUM(total_beneficiaries) as total_beneficiaries,
    ROUND(SUM(total_medicare_spend)/1000000,1) as total_medicare_spend_millions

FROM supplier_totals
GROUP BY 1
HAVING supplier_count >= 5 -- Ensure reasonable sample size
ORDER BY total_medicare_spend_millions DESC;

-- How this works:
-- 1. Creates a CTE that aggregates spending by supplier across major DMEPOS categories
-- 2. Calculates percentage distribution of spend across categories
-- 3. Summarizes at state level to show geographic patterns
-- 4. Filters for meaningful business volumes

-- Assumptions & Limitations:
-- - Uses 2022 data only - trends over time not captured
-- - Excludes small suppliers (<$100k annual Medicare payments)
-- - Requires minimum 5 suppliers per state for privacy/statistical validity
-- - Medicare payments used rather than allowed amounts or submitted charges

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Break out by supplier specialty or rural/urban status
-- 3. Correlate with beneficiary demographic factors
-- 4. Add supplier-level details like average payment per beneficiary
-- 5. Include analysis of standardized payment amounts for geographic comparison

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:09:31.061577
    - Additional Notes: Query provides state-level analysis of DMEPOS Medicare spending distribution across DME, prosthetics/orthotics, and drug categories. Includes volume filters ($100k+ suppliers, 5+ suppliers per state) to ensure meaningful comparisons. Uses 2022 data only and focuses on Medicare payments rather than total allowed amounts.
    
    */