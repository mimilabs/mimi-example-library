-- payer_market_share_trends.sql

-- Business Purpose: 
-- Analyze market share trends across payers over time to:
-- - Track payer market position changes
-- - Identify emerging market leaders and declining players
-- - Support strategic planning and competitive analysis
-- - Enable data-driven market entry/exit decisions

WITH annual_coverage AS (
    -- Calculate patient counts per payer per year
    SELECT 
        payer,
        start_year AS coverage_year,
        COUNT(DISTINCT patient) as patient_count
    FROM mimi_ws_1.synthea.payer_transitions
    WHERE start_year IS NOT NULL 
    GROUP BY payer, start_year
),

total_patients_per_year AS (
    -- Get total patients covered each year for market share calculation
    SELECT 
        coverage_year,
        SUM(patient_count) as total_patients
    FROM annual_coverage
    GROUP BY coverage_year
)

SELECT 
    ac.coverage_year,
    ac.payer,
    ac.patient_count,
    tp.total_patients,
    ROUND(100.0 * ac.patient_count / tp.total_patients, 2) as market_share_pct,
    -- Calculate year-over-year change in market share
    ROUND(100.0 * ac.patient_count / tp.total_patients - 
        LAG(100.0 * ac.patient_count / tp.total_patients) 
        OVER (PARTITION BY ac.payer ORDER BY ac.coverage_year), 2) as market_share_change_pct
FROM annual_coverage ac
JOIN total_patients_per_year tp 
    ON ac.coverage_year = tp.coverage_year
WHERE ac.coverage_year >= 2010  -- Focus on recent years
ORDER BY ac.coverage_year DESC, market_share_pct DESC;

-- How this query works:
-- 1. Creates annual patient counts by payer using the start_year
-- 2. Calculates total covered patients per year
-- 3. Computes market share percentages and year-over-year changes
-- 4. Orders results to highlight largest market players and recent trends

-- Assumptions and Limitations:
-- - Uses start_year as the point of measurement for market share
-- - Assumes one patient can only be with one payer at a time
-- - Limited to years where data is available
-- - Synthetic data may not reflect real market dynamics

-- Possible Extensions:
-- 1. Add geographic segmentation for regional market share analysis
-- 2. Include ownership type to compare public vs private market share
-- 3. Create market concentration metrics (e.g., Herfindahl Index)
-- 4. Add forecasting of market share trends
-- 5. Include analysis of market share by specific patient demographics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:38:15.313592
    - Additional Notes: Query calculates annual market share percentages and changes for each payer, with results focused on years from 2010 onward. Market share is based on distinct patient counts, assuming single-payer coverage at any given time. Performance may be impacted with very large datasets due to window functions.
    
    */