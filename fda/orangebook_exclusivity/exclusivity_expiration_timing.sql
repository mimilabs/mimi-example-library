-- Title: FDA Drug Exclusivity Timing and Portfolio Analysis
--
-- Business Purpose:
-- This analysis helps pharmaceutical companies and investors understand:
-- 1. The current active exclusivity landscape and remaining durations
-- 2. Portfolio concentration among drug manufacturers
-- 3. Strategic timing of exclusivity expirations for business planning
--
-- The insights support market entry timing, portfolio management, and competitive strategy

WITH current_exclusivity AS (
    -- Get the most recent exclusivity data for each drug
    SELECT 
        appl_type,
        appl_no,
        product_no,
        exclusivity_code,
        exclusivity_date,
        mimi_src_file_date
    FROM mimi_ws_1.fda.orangebook_exclusivity
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.fda.orangebook_exclusivity)
),

time_to_expiry AS (
    -- Calculate remaining exclusivity duration
    SELECT 
        appl_type,
        exclusivity_code,
        DATEDIFF(days, CURRENT_DATE(), exclusivity_date) as days_to_expiry,
        COUNT(*) as drug_count
    FROM current_exclusivity
    WHERE exclusivity_date > CURRENT_DATE()
    GROUP BY appl_type, exclusivity_code, exclusivity_date
)

SELECT 
    appl_type,
    exclusivity_code,
    -- Categorize time windows for strategic planning
    CASE 
        WHEN days_to_expiry <= 180 THEN '0-6 months'
        WHEN days_to_expiry <= 365 THEN '6-12 months'
        WHEN days_to_expiry <= 730 THEN '1-2 years'
        ELSE 'Over 2 years'
    END as expiry_window,
    SUM(drug_count) as products_in_window,
    -- Calculate percentage within application type
    ROUND(100.0 * SUM(drug_count) / 
          SUM(SUM(drug_count)) OVER (PARTITION BY appl_type), 1) as pct_of_type
FROM time_to_expiry
GROUP BY 
    appl_type,
    exclusivity_code,
    CASE 
        WHEN days_to_expiry <= 180 THEN '0-6 months'
        WHEN days_to_expiry <= 365 THEN '6-12 months'
        WHEN days_to_expiry <= 730 THEN '1-2 years'
        ELSE 'Over 2 years'
    END
ORDER BY 
    appl_type,
    exclusivity_code,
    expiry_window;

-- How it works:
-- 1. Gets most recent exclusivity data snapshot
-- 2. Calculates days until exclusivity expiration for each drug
-- 3. Groups results into meaningful time windows for business planning
-- 4. Provides counts and percentages to understand portfolio distribution

-- Assumptions and Limitations:
-- - Uses current date as reference point for calculations
-- - Assumes most recent source file date represents current state
-- - Does not account for potential exclusivity extensions or challenges
-- - Focuses on time-based analysis rather than therapeutic areas

-- Possible Extensions:
-- 1. Add therapeutic category analysis by joining with product classification data
-- 2. Include manufacturer/sponsor analysis for competitive intelligence
-- 3. Add historical trending of exclusivity grants over time
-- 4. Incorporate patent expiration data for comprehensive lifecycle analysis
-- 5. Add revenue impact analysis by joining with sales data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:59:50.618700
    - Additional Notes: Query is optimized for point-in-time analysis of exclusivity expiration windows. For accurate results, ensure the source table is regularly updated and mimi_src_file_date reflects the latest FDA data publication. Time window categories (0-6 months, 6-12 months, etc.) are hardcoded and may need adjustment based on specific business needs.
    
    */