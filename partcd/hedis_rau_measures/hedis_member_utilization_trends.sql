-- HEDIS Member Utilization Trend Analysis
-- Purpose: Analyze member engagement and utilization patterns across HEDIS measures
-- to identify opportunities for improving member participation and care delivery.
-- Business Value: 
-- - Identifies measures with low member participation
-- - Highlights potential access to care issues
-- - Supports targeted member outreach strategies
-- - Informs resource allocation decisions

WITH measure_utilization AS (
    -- Calculate utilization metrics by measure and year
    SELECT 
        measure_name,
        hedis_year,
        COUNT(DISTINCT contract_number) as number_of_contracts,
        SUM(member_count) as total_members,
        SUM(denominator) as total_eligible,
        SUM(observed_count) as total_observed,
        ROUND(SUM(observed_count) * 100.0 / NULLIF(SUM(denominator), 0), 2) as utilization_rate
    FROM mimi_ws_1.partcd.hedis_rau_measures
    WHERE denominator > 0  -- Exclude invalid denominators
    GROUP BY measure_name, hedis_year
)

SELECT 
    measure_name,
    hedis_year,
    number_of_contracts,
    total_members,
    total_eligible,
    total_observed,
    utilization_rate,
    -- Calculate year-over-year change in utilization
    utilization_rate - LAG(utilization_rate) 
        OVER (PARTITION BY measure_name ORDER BY hedis_year) as yoy_change
FROM measure_utilization
ORDER BY 
    -- Sort to highlight measures with lowest utilization
    hedis_year DESC,
    utilization_rate ASC;

-- How this query works:
-- 1. Creates a CTE to aggregate key utilization metrics by measure and year
-- 2. Calculates overall utilization rates and year-over-year changes
-- 3. Orders results to highlight potential problem areas

-- Assumptions:
-- - Denominators greater than zero represent valid measurement opportunities
-- - All contracts report consistently across years
-- - Member counts are accurate and deduplicated

-- Limitations:
-- - Does not account for measure-specific eligibility criteria
-- - Cannot identify specific reasons for low utilization
-- - Year-over-year comparisons may be affected by contract changes

-- Possible Extensions:
-- 1. Add geographic analysis by joining with contract region data
-- 2. Include statistical significance testing for utilization changes
-- 3. Create measure categories to group related services
-- 4. Add seasonality analysis for measures with monthly patterns
-- 5. Incorporate member demographic factors if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:33:36.535583
    - Additional Notes: The query focuses on member participation patterns and can help identify access to care gaps. Note that utilization rates may be skewed for measures with small denominators, and year-over-year comparisons should consider potential changes in contract participation or reporting requirements.
    
    */