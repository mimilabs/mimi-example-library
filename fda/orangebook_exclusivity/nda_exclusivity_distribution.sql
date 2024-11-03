-- Title: Strategic Analysis of New Drug Application (NDA) Exclusivity Distribution
-- Business Purpose:
-- This query analyzes the distribution of exclusivity types for New Drug Applications (NDAs)
-- to help stakeholders:
-- 1. Understand the most common types of market protection granted to innovative drugs
-- 2. Guide portfolio strategy by identifying prevalent exclusivity patterns
-- 3. Support market entry timing decisions based on exclusivity profiles

WITH current_exclusivity AS (
    -- Get the latest exclusivity data for each application/product
    SELECT DISTINCT
        appl_type,
        appl_no,
        product_no,
        exclusivity_code,
        exclusivity_date
    FROM mimi_ws_1.fda.orangebook_exclusivity
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.fda.orangebook_exclusivity)
),

exclusivity_summary AS (
    -- Analyze distribution of exclusivity types for NDAs
    SELECT 
        exclusivity_code,
        COUNT(DISTINCT appl_no) as num_applications,
        COUNT(DISTINCT CONCAT(appl_no, '-', product_no)) as num_products,
        ROUND(AVG(DATEDIFF(exclusivity_date, CURRENT_DATE))/365.25, 1) as avg_years_remaining
    FROM current_exclusivity
    WHERE appl_type = 'NDA' 
    AND exclusivity_date > CURRENT_DATE
    GROUP BY exclusivity_code
)

SELECT 
    exclusivity_code,
    num_applications,
    num_products,
    avg_years_remaining,
    ROUND(100.0 * num_applications / SUM(num_applications) OVER(), 1) as pct_of_total_applications
FROM exclusivity_summary
ORDER BY num_applications DESC;

-- How this query works:
-- 1. Creates a CTE to get the most recent exclusivity data
-- 2. Summarizes exclusivity distribution for NDAs only
-- 3. Calculates key metrics including application counts and average remaining exclusivity
-- 4. Adds percentage distribution to show relative frequency of each exclusivity type

-- Assumptions and Limitations:
-- 1. Focuses only on NDA applications (innovative drugs, not generics)
-- 2. Considers only active exclusivity periods (future expiration dates)
-- 3. Uses the most recent data snapshot only
-- 4. Assumes exclusivity codes are consistently applied across applications

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of exclusivity types
-- 2. Include therapeutic category analysis by joining with product tables
-- 3. Compare exclusivity patterns between different application types (NDA vs BLA)
-- 4. Add filters for specific therapeutic areas or manufacturers
-- 5. Create time-based cohort analysis of exclusivity grants

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:05:10.245758
    - Additional Notes: Query provides strategic view of exclusivity patterns for innovative drugs (NDAs only) with active market protection. Best used for portfolio planning and competitive intelligence. Note that percentages are calculated against total NDA applications, not total drug products.
    
    */