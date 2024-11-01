-- Title: Special Needs Plan (SNP) Market Analysis
-- Business Purpose:
-- - Analyze the distribution and characteristics of Special Needs Plans
-- - Identify market opportunities for specialized Medicare coverage
-- - Support strategic planning for organizations serving vulnerable populations
-- - Assess premium and cost-sharing structures for SNP offerings

SELECT 
    -- Plan identification
    contract_id,
    CASE 
        WHEN LEFT(contract_id, 1) = 'H' THEN 'Local MA'
        WHEN LEFT(contract_id, 1) = 'R' THEN 'Regional MA'
        WHEN LEFT(contract_id, 1) = 'S' THEN 'PDP'
    END as plan_type,
    
    -- SNP categorization
    CASE snp
        WHEN 0 THEN 'Not SNP'
        WHEN 1 THEN 'Chronic/Disabled'
        WHEN 2 THEN 'Dual-Eligible'
        WHEN 3 THEN 'Institutional'
    END as snp_type,
    
    -- Geographic grouping
    COALESCE(state, 'N/A') as state,
    
    -- Cost metrics
    AVG(premium) as avg_premium,
    AVG(deductible) as avg_deductible,
    COUNT(*) as plan_count,
    
    -- Calculate percentage of plans with zero premium
    SUM(CASE WHEN premium = 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) as zero_premium_pct,
    
    -- Latest data point
    MAX(mimi_src_file_date) as data_current_as_of

FROM mimi_ws_1.prescriptiondrugplan.plan_information
WHERE snp > 0  -- Focus on SNP plans only
  AND plan_suppressed_yn = 'N'  -- Exclude suppressed plans
GROUP BY 
    contract_id,
    LEFT(contract_id, 1),
    snp,
    COALESCE(state, 'N/A')
HAVING COUNT(*) > 0
ORDER BY 
    snp_type,
    state,
    plan_count DESC;

-- How this query works:
-- 1. Filters for Special Needs Plans (SNP > 0)
-- 2. Categorizes plans by type (Local MA, Regional MA, PDP)
-- 3. Groups SNPs into their three categories
-- 4. Calculates key metrics including premium averages and zero-premium prevalence
-- 5. Provides geographic distribution by state where applicable

-- Assumptions and Limitations:
-- - Assumes plan_suppressed_yn = 'N' indicates valid, active plans
-- - State information only available for Local MA plans
-- - Premium and deductible amounts are current for the latest reporting period
-- - Does not account for historical trends or changes over time

-- Possible Extensions:
-- 1. Add time-series analysis by incorporating mimi_src_file_date
-- 2. Include formulary analysis by joining with basic_drugs_formulary
-- 3. Add beneficiary cost-sharing analysis by joining with beneficiary_cost
-- 4. Incorporate geographic analysis using county_code for more granular insights
-- 5. Compare SNP vs non-SNP characteristics within same contract types
-- 6. Add market concentration metrics (HHI) by region/state
-- 7. Include pharmacy network analysis for accessibility assessment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:41:16.799462
    - Additional Notes: Query focuses on Special Needs Plans (SNP) market analysis at state level. Note that geographic analysis is limited for non-Local MA plans (R and S contracts) since state information is only available for H contracts. Zero-premium percentage calculation provides important market competitiveness insights.
    
    */