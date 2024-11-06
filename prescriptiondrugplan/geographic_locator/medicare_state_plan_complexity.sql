-- Title: Medicare Geographic Diversity and Plan Distribution Analysis

/* 
Business Purpose: 
Analyze the unique geographic spread of Medicare plans to identify potential market 
expansion opportunities and understand regional healthcare plan diversity. This query 
provides insights into the distribution of Medicare Advantage and Prescription Drug Plans 
across different states and counties, highlighting areas with complex or unique plan coverage.
*/

WITH plan_geographic_complexity AS (
    -- Aggregate plan diversity metrics by state
    SELECT 
        statename,
        COUNT(DISTINCT county_code) AS total_counties,
        COUNT(DISTINCT ma_region_code) AS unique_ma_regions,
        COUNT(DISTINCT pdp_region_code) AS unique_pdp_regions,
        -- Calculate a complexity score based on region diversity
        (COUNT(DISTINCT ma_region_code) + COUNT(DISTINCT pdp_region_code)) AS region_complexity_score
    FROM 
        mimi_ws_1.prescriptiondrugplan.geographic_locator
    GROUP BY 
        statename
),

state_ranking AS (
    -- Rank states by their plan distribution complexity
    SELECT 
        statename,
        total_counties,
        unique_ma_regions,
        unique_pdp_regions,
        region_complexity_score,
        RANK() OVER (ORDER BY region_complexity_score DESC) AS complexity_rank
    FROM 
        plan_geographic_complexity
)

-- Final query to highlight states with most diverse Medicare plan distributions
SELECT 
    statename,
    total_counties,
    unique_ma_regions,
    unique_pdp_regions,
    region_complexity_score,
    complexity_rank
FROM 
    state_ranking
WHERE 
    complexity_rank <= 10  -- Top 10 states with most complex plan distributions
ORDER BY 
    complexity_rank;

/* 
Query Mechanics:
1. First CTE (plan_geographic_complexity) calculates unique counties, MA regions, and PDP regions per state
2. Second CTE (state_ranking) ranks states by a calculated region complexity score
3. Final SELECT retrieves top 10 states with most diverse Medicare plan distributions

Assumptions and Limitations:
- Assumes equal weight for MA and PDP region diversity
- Uses current snapshot of geographic data
- Does not account for plan quality or enrollment numbers

Potential Extensions:
1. Add population data to normalize complexity score
2. Incorporate plan enrollment metrics
3. Time-series analysis of geographic plan distribution changes
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:33:47.145264
    - Additional Notes: Provides a ranking of states by their Medicare plan geographic diversity, focusing on MA and PDP region distribution complexity. Useful for identifying states with the most intricate healthcare plan landscapes.
    
    */