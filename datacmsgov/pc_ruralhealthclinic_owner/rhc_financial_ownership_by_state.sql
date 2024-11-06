-- rhc_owner_financial_profile.sql

-- Business Purpose:
-- Analyze the financial ownership structure of Rural Health Clinics to understand:
--   - Mix of financial vs non-financial institutional owners
--   - Average ownership stakes by institution type
--   - Concentration of financial ownership across clinics
-- This analysis helps identify potential investment opportunities and assess
-- financial stability risks in rural healthcare markets

-- Main Query
WITH financial_owners AS (
    SELECT 
        organization_name,
        state_owner,
        -- Identify if owner has any financial characteristics
        CASE WHEN 
            financial_institution_owner = 'Y' OR
            investment_firm_owner = 'Y' OR
            holding_company_owner = 'Y'
        THEN 1 ELSE 0 END as is_financial_owner,
        percentage_ownership,
        -- Classify specific financial owner type
        CASE 
            WHEN financial_institution_owner = 'Y' THEN 'Bank/Financial'
            WHEN investment_firm_owner = 'Y' THEN 'Investment Firm'
            WHEN holding_company_owner = 'Y' THEN 'Holding Company'
            ELSE 'Non-Financial'
        END as owner_financial_type
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
    WHERE type_owner = 'O' -- Focus on organizational owners
    AND percentage_ownership IS NOT NULL
)

SELECT 
    state_owner,
    COUNT(DISTINCT organization_name) as total_clinics,
    ROUND(AVG(percentage_ownership), 1) as avg_ownership_pct,
    ROUND(SUM(CASE WHEN is_financial_owner = 1 THEN 1 ELSE 0 END) * 100.0 / 
          COUNT(*), 1) as pct_financial_owners,
    -- Break down by financial owner type
    ROUND(AVG(CASE WHEN owner_financial_type = 'Bank/Financial' 
              THEN percentage_ownership END), 1) as avg_bank_ownership_pct,
    ROUND(AVG(CASE WHEN owner_financial_type = 'Investment Firm' 
              THEN percentage_ownership END), 1) as avg_investment_ownership_pct,
    ROUND(AVG(CASE WHEN owner_financial_type = 'Holding Company' 
              THEN percentage_ownership END), 1) as avg_holding_ownership_pct
FROM financial_owners
GROUP BY state_owner
HAVING COUNT(DISTINCT organization_name) >= 5 -- Filter for states with meaningful sample
ORDER BY pct_financial_owners DESC

-- How it works:
-- 1. Creates CTE to identify financial institution owners and their characteristics
-- 2. Calculates state-level metrics for financial ownership presence and concentration
-- 3. Provides breakdown of average ownership percentages by financial institution type
-- 4. Filters for states with at least 5 clinics to ensure meaningful analysis

-- Assumptions & Limitations:
-- - Relies on accurate reporting of owner types in source data
-- - Does not capture indirect financial ownership through parent companies
-- - Limited to explicit financial institutions; may miss other financial actors
-- - State-level aggregation may mask local market concentrations

-- Possible Extensions:
-- 1. Add time-series analysis to track changes in financial ownership over time
-- 2. Include correlation with clinic performance or quality metrics
-- 3. Add geographic clustering analysis to identify regional financial ownership patterns
-- 4. Incorporate additional owner characteristics like for-profit status
-- 5. Add analysis of ownership transitions between financial and non-financial entities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:02:54.966146
    - Additional Notes: Query focuses on state-level aggregation of financial institutional ownership in rural health clinics. Excludes states with fewer than 5 clinics to ensure statistical relevance. Financial owners are identified through three main categories: banks/financial institutions, investment firms, and holding companies. Results include both ownership percentages and presence metrics to provide a comprehensive view of financial control patterns.
    
    */