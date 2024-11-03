-- RBCS Subcategory Duration Impact Analysis
--
-- Business Purpose: 
-- Analyzes the average lifespan of medical procedures within each RBCS subcategory
-- to help healthcare organizations understand service stability and make informed
-- decisions about long-term service line investments. This analysis provides
-- insights into which medical specialties have more established vs frequently
-- changing procedure codes.

WITH procedure_duration AS (
    -- Calculate the duration for each procedure code
    SELECT 
        hcpcs_cd,
        rbcs_cat_subcat,
        rbcs_subcat_desc,
        -- Use current date for NULL end dates to handle active codes
        DATEDIFF(
            day,
            hcpcs_cd_add_dt,
            COALESCE(hcpcs_cd_end_dt, CURRENT_DATE)
        ) / 365.0 as years_active
    FROM mimi_ws_1.datacmsgov.betos
    WHERE hcpcs_cd_add_dt IS NOT NULL
),

subcategory_metrics AS (
    -- Aggregate metrics at the subcategory level
    SELECT 
        rbcs_cat_subcat,
        rbcs_subcat_desc,
        COUNT(hcpcs_cd) as total_procedures,
        ROUND(AVG(years_active), 1) as avg_years_active,
        ROUND(MIN(years_active), 1) as min_years_active,
        ROUND(MAX(years_active), 1) as max_years_active
    FROM procedure_duration
    GROUP BY rbcs_cat_subcat, rbcs_subcat_desc
)

-- Final output with subcategories ranked by stability
SELECT 
    rbcs_cat_subcat,
    rbcs_subcat_desc,
    total_procedures,
    avg_years_active,
    min_years_active,
    max_years_active,
    RANK() OVER (ORDER BY avg_years_active DESC) as stability_rank
FROM subcategory_metrics
WHERE total_procedures >= 5  -- Filter for meaningful subcategories
ORDER BY avg_years_active DESC;

-- How it works:
-- 1. First CTE calculates the duration of each procedure code
-- 2. Second CTE aggregates statistics at the subcategory level
-- 3. Final query ranks subcategories by average procedure duration
-- 4. Results show which medical specialties have more stable procedure codes

-- Assumptions and limitations:
-- 1. NULL end dates are treated as currently active procedures
-- 2. Requires at least 5 procedures per subcategory for meaningful analysis
-- 3. Does not account for frequency of procedure usage
-- 4. Historical changes in coding practices may affect interpretation

-- Possible extensions:
-- 1. Add trending analysis to show how stability changes over time periods
-- 2. Include procedure complexity (major_ind) in the analysis
-- 3. Compare stability across main categories (rbcs_cat)
-- 4. Add volume weighting based on Medicare claims data
-- 5. Analyze seasonal patterns in procedure code changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:13:24.217289
    - Additional Notes: Query focuses on longevity patterns of medical procedures which can be valuable for strategic planning. Note that the stability metrics may be skewed for newer subcategories or those with recent major revisions to coding standards. Consider additional filtering or weighting if using for investment decisions.
    
    */