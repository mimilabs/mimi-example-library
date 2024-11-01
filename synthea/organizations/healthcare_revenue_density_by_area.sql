-- Healthcare_Organization_Revenue_Density.sql

-- Business Purpose:
-- - Calculate revenue density per square mile to identify high-value healthcare markets
-- - Support strategic planning for market expansion and investment
-- - Guide resource allocation based on revenue concentration
-- - Identify potentially underserved but high-value areas

WITH org_coordinates AS (
    -- Calculate revenue density using geographic coordinates
    SELECT 
        state,
        city,
        COUNT(*) as org_count,
        SUM(revenue) as total_revenue,
        MIN(lat) as min_lat,
        MAX(lat) as max_lat,
        MIN(lon) as min_lon,
        MAX(lon) as max_lon,
        -- Approximate area calculation using coordinate differences
        (MAX(lat) - MIN(lat)) * (MAX(lon) - MIN(lon)) * 69 * 69 as approx_area_sqmiles
    FROM mimi_ws_1.synthea.organizations
    WHERE revenue > 0 
    AND lat IS NOT NULL 
    AND lon IS NOT NULL
    GROUP BY state, city
)

SELECT 
    state,
    city,
    org_count,
    ROUND(total_revenue/1000000, 2) as total_revenue_millions,
    ROUND(approx_area_sqmiles, 2) as area_sqmiles,
    ROUND(total_revenue/NULLIF(approx_area_sqmiles, 0)/1000000, 2) as revenue_density_millions_per_sqmile,
    ROUND(org_count/NULLIF(approx_area_sqmiles, 0), 2) as org_density_per_sqmile
FROM org_coordinates
WHERE approx_area_sqmiles > 0
ORDER BY revenue_density_millions_per_sqmile DESC
LIMIT 20;

-- How it works:
-- 1. Creates a CTE to calculate geographic boundaries and areas for each city
-- 2. Calculates total revenue and organization count per area
-- 3. Computes revenue density and organization density metrics
-- 4. Returns top 20 markets by revenue density

-- Assumptions and Limitations:
-- - Uses simplified area calculation (rectangular approximation)
-- - Assumes coordinates are accurate and organizations are properly geocoded
-- - Excludes records with missing coordinates or zero revenue
-- - Area calculation may be less accurate at extreme latitudes

-- Possible Extensions:
-- 1. Add time-based trending of revenue density
-- 2. Include utilization metrics for capacity analysis
-- 3. Compare against demographic data for market potential
-- 4. Add competitive analysis by calculating market share within dense areas
-- 5. Incorporate distance-based clustering for more accurate market definition

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:45:07.973429
    - Additional Notes: Area calculations use approximation based on coordinate bounding boxes which may overestimate actual service areas. Script performs best for analyzing metropolitan regions rather than rural areas due to coordinate-based calculations. Consider adjusting the revenue threshold (currently >0) based on specific market analysis needs.
    
    */