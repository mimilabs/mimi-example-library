-- real_estate_investment_metro_performance_ranking.sql

/**
 * Business Purpose:
 * Identify top-performing metropolitan areas for real estate investment
 * by analyzing home value appreciation and ranking metros based on
 * their growth potential and consistency.
 *
 * Key Business Insights:
 * - Rank metro areas by total home value appreciation
 * - Highlight metros with most consistent growth
 * - Support real estate investment strategy and market analysis
 */

WITH metro_performance AS (
    -- Calculate key performance metrics for each metro area
    SELECT 
        metro,
        state,
        COUNT(DISTINCT zip) AS zip_count,
        
        -- Calculate total home value appreciation
        MAX(value) - MIN(value) AS total_appreciation,
        
        -- Calculate annualized growth rate
        ((MAX(value) / MIN(value)) - 1) * 100 AS appreciation_percentage,
        
        -- Measure growth consistency using coefficient of variation
        STDDEV(value) / AVG(value) * 100 AS growth_volatility,
        
        MIN(date) AS earliest_date,
        MAX(date) AS latest_date
    FROM 
        mimi_ws_1.zillow.homevalue_zip
    WHERE 
        metro IS NOT NULL
    GROUP BY 
        metro, state
),

ranked_metros AS (
    -- Rank metros by multiple performance criteria
    SELECT 
        metro,
        state,
        zip_count,
        total_appreciation,
        appreciation_percentage,
        growth_volatility,
        earliest_date,
        latest_date,
        
        -- Create composite ranking considering multiple factors
        RANK() OVER (ORDER BY appreciation_percentage DESC) AS appreciation_rank,
        RANK() OVER (ORDER BY growth_volatility ASC) AS stability_rank
    FROM 
        metro_performance
)

-- Final selection of top performing metros
SELECT 
    metro,
    state,
    zip_count,
    ROUND(total_appreciation, 2) AS total_appreciation,
    ROUND(appreciation_percentage, 2) AS appreciation_percentage,
    ROUND(growth_volatility, 2) AS growth_volatility,
    earliest_date,
    latest_date,
    appreciation_rank,
    stability_rank
FROM 
    ranked_metros
WHERE 
    -- Focus on metros with at least 5 zip codes for meaningful analysis
    zip_count >= 5
ORDER BY 
    appreciation_percentage DESC
LIMIT 25;

/**
 * Query Execution Details:
 * 1. Aggregates home value data by metropolitan area
 * 2. Calculates total appreciation and growth percentage
 * 3. Measures growth consistency via volatility metric
 * 4. Ranks metros based on multiple performance criteria
 *
 * Assumptions & Limitations:
 * - Uses Zillow Home Value Index as primary valuation metric
 * - Assumes data completeness and accuracy
 * - Limited to metros with 5+ zip codes
 * - Does not account for localized market nuances
 *
 * Potential Extensions:
 * 1. Add median home value comparison
 * 2. Incorporate more granular regional segmentation
 * 3. Include additional economic indicators
 * 4. Create time-windowed performance analysis
 */

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:00:59.052686
    - Additional Notes: Query provides comprehensive real estate investment insights by analyzing metropolitan area home value performance across multiple metrics like appreciation, consistency, and growth potential.
    
    */