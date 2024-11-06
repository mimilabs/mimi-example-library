-- geographic_research_distribution.sql
-- BUSINESS PURPOSE:
-- Analyze the geographic distribution of research investments across states to identify:
-- 1. Regional research hubs and potential underserved areas
-- 2. State-level investment patterns that could inform market expansion
-- 3. Correlation between research spending and population centers
-- This analysis helps stakeholders make informed decisions about research site selection,
-- resource allocation, and market development opportunities.

WITH state_totals AS (
    -- Aggregate research payments by state
    SELECT 
        recipient_state,
        COUNT(DISTINCT record_id) as num_payments,
        COUNT(DISTINCT applicable_manufacturer_or_applicable_gpo_making_payment_name) as num_manufacturers,
        COUNT(DISTINCT teaching_hospital_name) as num_institutions,
        SUM(total_amount_of_payment_us_dollars) as total_research_dollars,
        AVG(total_amount_of_payment_us_dollars) as avg_payment_amount
    FROM mimi_ws_1.openpayments.research
    WHERE recipient_state IS NOT NULL
        AND recipient_country = 'United States'
        AND total_amount_of_payment_us_dollars > 0
    GROUP BY recipient_state
),

state_rankings AS (
    -- Calculate rankings for key metrics
    SELECT 
        recipient_state,
        num_payments,
        num_manufacturers,
        num_institutions,
        total_research_dollars,
        avg_payment_amount,
        RANK() OVER (ORDER BY total_research_dollars DESC) as dollars_rank,
        RANK() OVER (ORDER BY num_institutions DESC) as institutions_rank
    FROM state_totals
)

-- Final output with key metrics and rankings
SELECT 
    recipient_state as state,
    num_payments as total_transactions,
    num_manufacturers as unique_manufacturers,
    num_institutions as research_institutions,
    ROUND(total_research_dollars, 2) as total_research_amount,
    ROUND(avg_payment_amount, 2) as avg_payment,
    dollars_rank as research_dollars_rank,
    institutions_rank as institutions_rank,
    CASE 
        WHEN dollars_rank <= 10 THEN 'Top 10 Research Hub'
        WHEN dollars_rank <= 25 THEN 'Major Research Center'
        ELSE 'Developing Research Market'
    END as market_classification
FROM state_rankings
ORDER BY total_research_dollars DESC;

/* HOW IT WORKS:
1. First CTE (state_totals) aggregates key metrics by state
2. Second CTE (state_rankings) adds rankings for total dollars and institutions
3. Final query adds market classification and formats output

ASSUMPTIONS AND LIMITATIONS:
- Only includes US-based research payments
- Assumes state is a meaningful unit of analysis
- Does not account for population differences between states
- Does not consider year-over-year trends
- May include some research sites with multiple locations

POSSIBLE EXTENSIONS:
1. Add population normalization (research dollars per capita)
2. Include year-over-year growth rates
3. Add therapeutic area concentration by state
4. Include cross-border research activities
5. Add seasonal patterns in research spending
6. Compare academic vs. commercial research distribution
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:32:07.012194
    - Additional Notes: The query focuses on state-level research investment patterns and provides multiple performance metrics including transaction counts, unique manufacturer counts, and total research dollars. The market classification logic can be adjusted based on specific business needs. Consider adding data validation checks for state codes and payment amounts if data quality is a concern.
    
    */