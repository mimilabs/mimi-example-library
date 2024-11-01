-- manufacturer_portfolio_diversity.sql

-- Business Purpose: 
-- Analyze the diversity and strategic focus of biologics manufacturers by examining their
-- product portfolios across different routes of administration and dosage forms.
-- This helps identify:
-- 1. Market specialization strategies
-- 2. Technical capabilities and manufacturing complexity
-- 3. Potential partnership or acquisition targets based on delivery expertise

WITH manufacturer_portfolio AS (
    -- Get distinct product counts by manufacturer and delivery method
    SELECT 
        applicant,
        route_of_administration,
        dosage_form,
        COUNT(DISTINCT nru) as product_count,
        COUNT(DISTINCT proper_name) as unique_molecule_count
    FROM mimi_ws_1.fda.purplebook
    WHERE marketing_status = 'Active'
    GROUP BY applicant, route_of_administration, dosage_form
),

manufacturer_summary AS (
    -- Calculate portfolio metrics for each manufacturer
    SELECT 
        applicant,
        COUNT(DISTINCT route_of_administration) as delivery_route_count,
        COUNT(DISTINCT dosage_form) as dosage_form_count,
        SUM(product_count) as total_products,
        SUM(unique_molecule_count) as total_unique_molecules
    FROM manufacturer_portfolio
    GROUP BY applicant
),

top_routes AS (
    -- Get top routes for each manufacturer
    SELECT 
        applicant,
        CONCAT_WS(', ', 
            MAX(CASE WHEN route_rank = 1 THEN route_of_administration END),
            MAX(CASE WHEN route_rank = 2 THEN route_of_administration END),
            MAX(CASE WHEN route_rank = 3 THEN route_of_administration END)
        ) as primary_routes
    FROM (
        SELECT 
            applicant,
            route_of_administration,
            ROW_NUMBER() OVER (PARTITION BY applicant ORDER BY product_count DESC) as route_rank
        FROM manufacturer_portfolio
    )
    GROUP BY applicant
)

-- Final output combining metrics with delivery specialization
SELECT 
    m.applicant,
    m.total_products,
    m.total_unique_molecules,
    m.delivery_route_count,
    m.dosage_form_count,
    ROUND(m.total_products * 1.0 / m.delivery_route_count, 2) as products_per_route,
    t.primary_routes as top_delivery_routes
FROM manufacturer_summary m
JOIN top_routes t ON m.applicant = t.applicant
WHERE m.total_products >= 3  -- Focus on established manufacturers
ORDER BY m.total_products DESC
LIMIT 20;

-- How it works:
-- 1. First CTE gets product counts by manufacturer and delivery method
-- 2. Second CTE calculates portfolio diversity metrics
-- 3. Third CTE identifies top 3 routes for each manufacturer
-- 4. Final query combines metrics and adds top delivery routes
-- 5. Filters for meaningful analysis (3+ products)

-- Assumptions and Limitations:
-- 1. Only considers active products
-- 2. Treats different strengths as separate products
-- 3. Assumes current marketing status is accurate
-- 4. Limited to top 20 manufacturers by default
-- 5. Shows only top 3 delivery routes per manufacturer

-- Possible Extensions:
-- 1. Add year-over-year portfolio evolution
-- 2. Include therapeutic area analysis
-- 3. Compare with global manufacturer portfolios
-- 4. Add market size/value weighting
-- 5. Include patent/exclusivity analysis
-- 6. Add manufacturing complexity scoring

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:35:24.755154
    - Additional Notes: Query focuses on manufacturing capabilities analysis by providing insights into delivery route diversification and portfolio depth. Results highlight manufacturers with 3+ products and includes key metrics like products per delivery route and dosage form diversity. Best used for strategic analysis of manufacturing capabilities and potential partnership opportunities.
    
    */