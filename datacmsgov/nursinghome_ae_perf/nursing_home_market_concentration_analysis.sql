
-- nursing_home_affiliated_entity_market_concentration_analysis.sql
--
-- Business Purpose:
-- Analyze market concentration and competitive landscape of nursing home affiliated entities
-- by examining geographic spread, facility ownership types, and quality performance metrics.
-- This analysis helps investors, healthcare strategists, and policymakers understand 
-- the structural dynamics of nursing home ownership and performance.

WITH EntityMarketAnalysis AS (
    SELECT 
        affiliated_entity,
        affiliated_entity_id,
        number_of_facilities,
        number_of_states_and_territories_with_operations,
        
        -- Ownership Composition Analysis
        ROUND(percent_of_facilities_classified_as_forprofit, 2) AS for_profit_percentage,
        ROUND(percent_of_facilities_classified_as_nonprofit, 2) AS nonprofit_percentage,
        ROUND(percent_of_facilities_classified_as_governmentowned, 2) AS government_owned_percentage,
        
        -- Quality Performance Metrics
        ROUND(average_overall_5star_rating, 2) AS overall_quality_rating,
        ROUND(average_health_inspection_rating, 2) AS health_inspection_rating,
        ROUND(average_staffing_rating, 2) AS staffing_rating,
        
        -- Concentrated Market Indicators
        CASE 
            WHEN number_of_facilities > 50 THEN 'Large National Operator'
            WHEN number_of_facilities BETWEEN 11 AND 50 THEN 'Regional Operator'
            WHEN number_of_facilities BETWEEN 5 AND 10 THEN 'Small Regional Operator'
            ELSE 'Boutique Operator'
        END AS market_segment,
        
        -- Geographic Diversification Score
        CASE 
            WHEN number_of_states_and_territories_with_operations > 10 THEN 'Highly Diversified'
            WHEN number_of_states_and_territories_with_operations BETWEEN 5 AND 10 THEN 'Moderately Diversified'
            WHEN number_of_states_and_territories_with_operations BETWEEN 2 AND 4 THEN 'Limited Diversification'
            ELSE 'Single Market Focused'
        END AS geographic_diversification

    FROM mimi_ws_1.datacmsgov.nursinghome_ae_perf
)

SELECT 
    market_segment,
    geographic_diversification,
    COUNT(*) AS entity_count,
    ROUND(AVG(number_of_facilities), 2) AS avg_facilities_per_entity,
    ROUND(AVG(overall_quality_rating), 2) AS avg_quality_rating,
    ROUND(AVG(for_profit_percentage), 2) AS avg_for_profit_percentage

FROM EntityMarketAnalysis
GROUP BY market_segment, geographic_diversification
ORDER BY entity_count DESC, avg_quality_rating DESC
LIMIT 100;

-- Query Mechanics:
-- 1. Create a CTE to enrich and categorize nursing home affiliated entities
-- 2. Use case statements to create categorical variables for market segmentation
-- 3. Aggregate and analyze entities by market segment and geographic diversification
-- 4. Provide summary statistics to understand market structure

-- Assumptions and Limitations:
-- - Data represents a snapshot in time
-- - Categorizations are based on predefined thresholds
-- - Does not capture individual facility nuances
-- - Relies on CMS-reported metrics

-- Potential Extensions:
-- 1. Add financial performance metrics if available
-- 2. Incorporate time-series analysis to track changes
-- 3. Integrate with state-level regulatory data
-- 4. Create predictive models for market entry/expansion strategies


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:01:23.067326
    - Additional Notes: Query provides strategic market segmentation insights for nursing home affiliated entities, categorizing operators by facility count and geographic spread. Useful for healthcare investment and strategic planning purposes, but limited by snapshot data and predefined categorization thresholds.
    
    */