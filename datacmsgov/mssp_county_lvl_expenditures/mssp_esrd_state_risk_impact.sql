/* MSSP County Risk Score Impact Analysis
   Author: Healthcare Analytics Team
   Purpose: Analyze the relationship between risk scores and expenditures 
           for high-cost ESRD populations across states
   Business Value: Support strategic ACO planning by identifying states 
                  where risk score management could yield highest ROI
*/

WITH state_metrics AS (
    -- Calculate state-level aggregates for ESRD population
    SELECT 
        year,
        state_name,
        ROUND(AVG(per_capita_exp_esrd), 2) as avg_state_esrd_cost,
        ROUND(AVG(avg_risk_score_esrd), 3) as avg_state_esrd_risk,
        SUM(person_years_esrd) as total_state_esrd_members
    FROM mimi_ws_1.datacmsgov.mssp_county_lvl_expenditures
    WHERE year >= 2020
    GROUP BY year, state_name
),
ranked_states AS (
    -- Identify states with highest ESRD costs and member volumes
    SELECT 
        *,
        RANK() OVER (PARTITION BY year ORDER BY avg_state_esrd_cost DESC) as cost_rank,
        RANK() OVER (PARTITION BY year ORDER BY total_state_esrd_members DESC) as volume_rank
    FROM state_metrics
    WHERE total_state_esrd_members >= 100  -- Focus on states with material ESRD population
)
SELECT 
    year,
    state_name,
    avg_state_esrd_cost,
    avg_state_esrd_risk,
    total_state_esrd_members,
    ROUND((avg_state_esrd_cost * total_state_esrd_members)/1000000, 2) as total_spend_millions,
    cost_rank,
    volume_rank
FROM ranked_states
WHERE cost_rank <= 10 OR volume_rank <= 10  -- Focus on top 10 states by cost or volume
ORDER BY year DESC, total_spend_millions DESC;

/* How this query works:
   1. Creates state-level metrics for ESRD population
   2. Ranks states by both per capita cost and member volume
   3. Identifies states with highest impact opportunity based on costs and volume
   4. Calculates total spend to show financial magnitude

   Assumptions and limitations:
   - Focuses only on ESRD population as highest cost segment
   - Requires minimum 100 member-years to ensure statistical relevance
   - Limited to recent years (2020+) for current relevance
   
   Possible extensions:
   1. Add year-over-year trend analysis
   2. Include risk score to cost ratio analysis
   3. Expand to other enrollment types (Disabled, Aged/Dual)
   4. Add geographic region grouping
   5. Compare against national benchmarks
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:04:03.176665
    - Additional Notes: Query focuses on high-impact states for ESRD population management by combining cost and volume metrics. Filters for minimum 100 person-years ensures statistical reliability but may exclude some smaller states. Total spend calculation provides quick identification of largest opportunity areas for ACO risk management programs.
    
    */