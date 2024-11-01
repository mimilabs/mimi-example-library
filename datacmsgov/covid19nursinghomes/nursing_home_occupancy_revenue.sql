-- nursing_home_occupancy_financial_analysis.sql
-- Business Purpose: Analyze nursing home occupancy rates and capacity utilization
-- This analysis helps identify revenue optimization opportunities and operational efficiency
-- Key metrics include bed occupancy rates, regional variations, and trending patterns

WITH occupancy_metrics AS (
    SELECT 
        provider_state,
        week_ending,
        COUNT(DISTINCT federal_provider_number) as facilities_count,
        SUM(number_of_all_beds) as total_beds,
        SUM(total_number_of_occupied_beds) as total_occupied_beds,
        ROUND(SUM(total_number_of_occupied_beds) * 100.0 / NULLIF(SUM(number_of_all_beds), 0), 1) as occupancy_rate
    FROM mimi_ws_1.datacmsgov.covid19nursinghomes
    WHERE passed_quality_assurance_check = 'Y'
    AND number_of_all_beds > 0
    GROUP BY provider_state, week_ending
),

state_trends AS (
    SELECT 
        provider_state,
        AVG(occupancy_rate) as avg_occupancy_rate,
        MIN(occupancy_rate) as min_occupancy_rate,
        MAX(occupancy_rate) as max_occupancy_rate,
        AVG(total_beds) as avg_total_beds,
        AVG(facilities_count) as avg_facilities_count
    FROM occupancy_metrics
    GROUP BY provider_state
)

SELECT 
    st.provider_state,
    ROUND(st.avg_occupancy_rate, 1) as avg_occupancy_rate_pct,
    ROUND(st.min_occupancy_rate, 1) as min_occupancy_rate_pct,
    ROUND(st.max_occupancy_rate, 1) as max_occupancy_rate_pct,
    ROUND(st.avg_total_beds, 0) as avg_beds_per_state,
    ROUND(st.avg_facilities_count, 0) as avg_facilities_count,
    -- Calculate potential revenue impact assuming $300 daily rate
    ROUND((st.avg_total_beds * (0.85 - st.avg_occupancy_rate/100) * 300 * 365)/1000000, 2) 
        as potential_annual_revenue_opportunity_millions
FROM state_trends st
WHERE st.avg_occupancy_rate < 85  -- Focus on states below 85% occupancy
ORDER BY potential_annual_revenue_opportunity_millions DESC;

-- How this works:
-- 1. First CTE calculates weekly occupancy metrics by state
-- 2. Second CTE aggregates trends at the state level
-- 3. Main query identifies revenue opportunities in underperforming states
-- 4. Assumes industry benchmark of 85% optimal occupancy
-- 5. Calculates potential revenue opportunity based on gap to benchmark

-- Assumptions and Limitations:
-- 1. Requires quality-assured data ('passed_quality_assurance_check' = 'Y')
-- 2. Assumes $300 daily rate (adjust based on actual market rates)
-- 3. Does not account for seasonal variations
-- 4. Limited to facilities reporting valid bed counts
-- 5. Revenue opportunity calculation is simplified

-- Possible Extensions:
-- 1. Add seasonal adjustment factors
-- 2. Include facility-level quality metrics
-- 3. Incorporate local market rates instead of flat $300
-- 4. Add staffing level analysis
-- 5. Include geographical clustering analysis
-- 6. Add year-over-year trend comparisons

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:20:00.427727
    - Additional Notes: Query focuses on revenue optimization by identifying states with low occupancy rates. The $300 daily rate assumption should be adjusted based on regional market rates. Query requires complete bed count data and quality-assured submissions for accurate results.
    
    */