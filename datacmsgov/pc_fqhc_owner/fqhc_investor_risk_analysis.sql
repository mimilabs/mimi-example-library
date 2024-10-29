-- fqhc_investor_backed_risk.sql

-- Business Purpose:
-- Analyze potential financial risk exposure in FQHCs by identifying:
-- 1. FQHCs with significant investment firm/financial institution ownership
-- 2. Concentration of financially-driven ownership structures
-- 3. Geographic distribution of investor-backed FQHCs
-- This enables healthcare regulators and policymakers to:
-- - Monitor financial stability risks
-- - Ensure continued focus on community health mission
-- - Target oversight of investor-owned facilities

WITH investor_backed AS (
    -- Identify FQHCs with investment firm or financial institution ownership
    SELECT 
        organization_name,
        state_owner,
        percentage_ownership,
        CASE 
            WHEN investment_firm_owner = 'Y' THEN 'Investment Firm'
            WHEN financial_institution_owner = 'Y' THEN 'Financial Institution'
            WHEN created_for_acquisition_owner = 'Y' THEN 'Acquisition Vehicle'
        END as investor_type,
        for_profit_owner
    FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
    WHERE (investment_firm_owner = 'Y' 
           OR financial_institution_owner = 'Y'
           OR created_for_acquisition_owner = 'Y')
        AND percentage_ownership >= 20  -- Focus on significant ownership stakes
),

risk_metrics AS (
    -- Calculate key risk indicators by state
    SELECT 
        state_owner,
        COUNT(DISTINCT organization_name) as investor_backed_count,
        AVG(percentage_ownership) as avg_ownership_stake,
        SUM(CASE WHEN for_profit_owner = 'Y' THEN 1 ELSE 0 END) as for_profit_count,
        SUM(CASE WHEN investor_type = 'Investment Firm' THEN 1 
            WHEN investor_type = 'Financial Institution' THEN 1 
            ELSE 0 END) as financial_investor_count
    FROM investor_backed
    WHERE state_owner IS NOT NULL
    GROUP BY state_owner
)

-- Final output with risk assessment
SELECT 
    state_owner,
    investor_backed_count,
    ROUND(avg_ownership_stake, 1) as avg_ownership_pct,
    for_profit_count,
    financial_investor_count,
    CASE 
        WHEN investor_backed_count >= 5 AND avg_ownership_stake >= 50 THEN 'High'
        WHEN investor_backed_count >= 3 OR avg_ownership_stake >= 40 THEN 'Medium'
        ELSE 'Low'
    END as risk_level
FROM risk_metrics
WHERE investor_backed_count > 0
ORDER BY investor_backed_count DESC, avg_ownership_stake DESC;

-- How this works:
-- 1. First CTE identifies FQHCs with significant investor ownership
-- 2. Second CTE calculates state-level risk metrics
-- 3. Final query adds risk level classification and formats output

-- Assumptions and limitations:
-- - 20% ownership threshold for "significant" stake
-- - Risk levels are illustrative and should be calibrated to policy goals
-- - Limited to explicit investment/financial ownership markers
-- - Does not account for indirect ownership through holding companies

-- Possible extensions:
-- 1. Add trending over time to identify acceleration in investor ownership
-- 2. Include FQHC size/revenue metrics to weight risk assessment
-- 3. Cross-reference with quality metrics to assess impact
-- 4. Add drill-down capability to specific investor organizations
-- 5. Incorporate social vulnerability indices for enhanced risk context

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:13:13.802005
    - Additional Notes: The query focuses on financial investment exposure in FQHCs using a 20% ownership threshold, which may need adjustment based on regulatory requirements. Risk level classifications (High/Medium/Low) are simplified and should be calibrated to specific policy needs. The analysis excludes indirect ownership structures that might mask additional financial institution involvement.
    
    */