-- Healthcare Access and Socioeconomic Risk Analysis by State 2014
-- Business Purpose: Analyze healthcare access challenges across states by combining 
-- uninsured rates with key socioeconomic vulnerability indicators. This helps
-- healthcare organizations and policymakers identify areas needing targeted
-- intervention programs and resource allocation.

WITH state_metrics AS (
    -- Aggregate county-level data to state level with weighted averages
    SELECT 
        state,
        st_abbr,
        SUM(e_totpop) as total_population,
        SUM(e_uninsur) as total_uninsured,
        -- Calculate weighted average of poverty and unemployment
        SUM(e_pov * e_totpop) / SUM(e_totpop) as weighted_poverty_rate,
        SUM(e_unemp * e_totpop) / SUM(e_totpop) as weighted_unemployment_rate,
        -- Calculate weighted average of per capita income
        SUM(e_pci * e_totpop) / SUM(e_totpop) as weighted_per_capita_income
    FROM mimi_ws_1.cdc.svi_county_y2014
    GROUP BY state, st_abbr
)

SELECT 
    state,
    st_abbr,
    total_population,
    -- Calculate uninsured rate
    ROUND((total_uninsured / total_population) * 100, 1) as uninsured_rate,
    ROUND(weighted_poverty_rate, 1) as poverty_rate,
    ROUND(weighted_unemployment_rate, 1) as unemployment_rate,
    ROUND(weighted_per_capita_income, 0) as per_capita_income,
    -- Create composite risk score (higher score = higher risk)
    ROUND(
        (weighted_poverty_rate * 0.4) + 
        (weighted_unemployment_rate * 0.3) + 
        ((total_uninsured / total_population) * 100 * 0.3)
    , 2) as healthcare_access_risk_score
FROM state_metrics
ORDER BY healthcare_access_risk_score DESC;

-- How this works:
-- 1. Creates a CTE to aggregate county-level data to state level
-- 2. Uses population-weighted averages to account for varying county sizes
-- 3. Combines uninsured rates with socioeconomic indicators
-- 4. Creates a composite risk score weighted toward poverty (40%), with unemployment 
--    and uninsured rates each contributing 30%

-- Assumptions and Limitations:
-- - Assumes current uninsured status is correlated with healthcare access barriers
-- - Does not account for Medicaid expansion status or state-specific programs
-- - Weighted averages may mask significant intra-state variations
-- - 2014 data may not reflect current conditions

-- Possible Extensions:
-- 1. Add time-series comparison by joining with other years
-- 2. Include healthcare facility density from other data sources
-- 3. Segment analysis by urban/rural counties
-- 4. Add state policy variables (e.g., Medicaid expansion status)
-- 5. Create regional comparisons or peer state groupings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:44:27.257221
    - Additional Notes: Query uses population-weighted averaging which smooths out county-level variations. The composite risk score weights (40% poverty, 30% unemployment, 30% uninsured) are configurable parameters that can be adjusted based on specific program needs. Consider local healthcare policy context when interpreting results.
    
    */