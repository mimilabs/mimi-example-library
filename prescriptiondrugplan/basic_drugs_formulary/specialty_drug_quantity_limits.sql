-- Title: Medicare Part D Specialty Drug Quantity Limit Patterns
-- Business Purpose:
-- Analyzes quantity limit patterns for high-tier (specialty) drugs across formularies to:
-- 1. Identify formularies with restrictive quantity limits on specialty medications
-- 2. Help understand patient access barriers for high-cost specialty drugs
-- 3. Support formulary optimization and patient access strategies

WITH specialty_drugs AS (
    -- Identify specialty tier drugs (typically tier 4 and 5)
    SELECT DISTINCT
        formulary_id,
        contract_year,
        rxcui,
        ndc,
        tier_level_value,
        quantity_limit_yn,
        quantity_limit_amount,
        quantity_limit_days
    FROM mimi_ws_1.prescriptiondrugplan.basic_drugs_formulary
    WHERE tier_level_value >= 4
    AND quantity_limit_yn = 'Y'
    AND contract_year = 2024  -- Focus on current contract year
),

formulary_metrics AS (
    -- Calculate quantity limit metrics by formulary
    SELECT 
        formulary_id,
        COUNT(DISTINCT rxcui) as total_specialty_drugs,
        AVG(CAST(quantity_limit_amount AS FLOAT)) as avg_quantity_limit,
        AVG(CAST(quantity_limit_days AS FLOAT)) as avg_limit_days,
        COUNT(CASE WHEN quantity_limit_days <= 30 THEN 1 END) as restricted_drugs_30day
    FROM specialty_drugs
    GROUP BY formulary_id
)

SELECT 
    fm.formulary_id,
    fm.total_specialty_drugs,
    ROUND(fm.avg_quantity_limit, 2) as avg_quantity_limit,
    ROUND(fm.avg_limit_days, 1) as avg_limit_days,
    fm.restricted_drugs_30day,
    ROUND(100.0 * fm.restricted_drugs_30day / fm.total_specialty_drugs, 1) as pct_restricted_30day
FROM formulary_metrics fm
WHERE fm.total_specialty_drugs >= 10  -- Focus on formularies with meaningful specialty drug coverage
ORDER BY pct_restricted_30day DESC
LIMIT 100;

-- How it works:
-- 1. First CTE identifies specialty drugs with quantity limits
-- 2. Second CTE calculates key metrics per formulary
-- 3. Final query returns formularies ranked by restriction severity
-- 4. Filters ensure meaningful results by excluding small formularies

-- Assumptions and Limitations:
-- 1. Assumes tiers 4+ represent specialty drugs (may vary by plan)
-- 2. Focuses only on quantity limits, not other restrictions
-- 3. Current year analysis only - historical trends not included
-- 4. Minimum threshold of 10 specialty drugs may need adjustment

-- Possible Extensions:
-- 1. Add therapeutic class analysis to identify most restricted categories
-- 2. Compare restrictions across different contract years
-- 3. Join with plan_information to analyze by organization type
-- 4. Include prior authorization and step therapy in restriction analysis
-- 5. Add geographic analysis by joining plan service area data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:22:29.278782
    - Additional Notes: Query focuses specifically on plans with 10+ specialty drugs and current year data. The 30-day threshold for restricted drugs is a key metric that may need adjustment based on specific analysis needs. Consider memory usage when running across large formulary datasets.
    
    */