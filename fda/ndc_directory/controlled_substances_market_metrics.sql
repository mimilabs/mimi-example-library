-- Title: Controlled Substances Portfolio Analysis
--
-- Business Purpose:
-- This analysis provides strategic insights into the controlled substances market by:
-- - Identifying the distribution of DEA schedules across drug products
-- - Analyzing manufacturer concentration in controlled substances
-- - Highlighting potential risk areas in scheduled drug availability
-- - Supporting controlled substance compliance monitoring

SELECT 
    -- DEA Schedule grouping
    CASE 
        WHEN dea_schedule = '2' THEN 'Schedule II'
        WHEN dea_schedule = '3' THEN 'Schedule III'
        WHEN dea_schedule = '4' THEN 'Schedule IV'
        WHEN dea_schedule = '5' THEN 'Schedule V'
        WHEN dea_schedule = '1' THEN 'Schedule I'
        ELSE 'Non-Controlled'
    END AS schedule_category,
    
    -- Count distinct products and manufacturers
    COUNT(DISTINCT product_ndc) as product_count,
    COUNT(DISTINCT manufacturer_name) as manufacturer_count,
    
    -- Calculate active products (not discontinued)
    SUM(CASE WHEN marketing_end_date IS NULL THEN 1 ELSE 0 END) as active_products,
    
    -- Get most common dosage form
    MAX(dosage_form) as primary_dosage_form,
    
    -- Calculate market concentration
    COUNT(DISTINCT product_ndc) / COUNT(DISTINCT manufacturer_name) as products_per_manufacturer,
    
    -- Calculate percentage of active products
    ROUND(100.0 * SUM(CASE WHEN marketing_end_date IS NULL THEN 1 ELSE 0 END) / 
          COUNT(product_ndc), 2) as active_product_percentage

FROM mimi_ws_1.fda.ndc_directory
WHERE dea_schedule IS NOT NULL 
    AND marketing_start_date IS NOT NULL

GROUP BY 
    CASE 
        WHEN dea_schedule = '2' THEN 'Schedule II'
        WHEN dea_schedule = '3' THEN 'Schedule III'
        WHEN dea_schedule = '4' THEN 'Schedule IV'
        WHEN dea_schedule = '5' THEN 'Schedule V'
        WHEN dea_schedule = '1' THEN 'Schedule I'
        ELSE 'Non-Controlled'
    END

ORDER BY 
    schedule_category;

-- How this query works:
-- 1. Groups drugs by DEA schedule using CASE statement
-- 2. Calculates key metrics for each schedule:
--    - Total distinct products
--    - Number of manufacturers
--    - Currently marketed products
--    - Primary dosage form
--    - Products per manufacturer ratio
--    - Percentage of active products
-- 3. Filters for products with DEA scheduling and known marketing start dates
-- 4. Orders results by schedule category for easy reading

-- Assumptions and Limitations:
-- - Assumes DEA schedule data is current and accurate
-- - Limited to products with marketing start dates
-- - Does not account for temporary drug shortages
-- - Manufacturer counts may include subsidiaries as separate entities
-- - Primary dosage form shows just one example form per schedule

-- Possible Extensions:
-- 1. Add time-based analysis to track schedule changes
-- 2. Include geographic distribution of manufacturers
-- 3. Cross-reference with drug shortage databases
-- 4. Add specific therapeutic category analysis within schedules
-- 5. Include market share analysis for major manufacturers
-- 6. Add pricing data analysis where available
-- 7. Compare brand vs generic distribution in each schedule

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:32:46.117349
    - Additional Notes: Query provides a high-level overview of the controlled substances market segmentation and manufacturer concentration. The active_product_percentage and products_per_manufacturer metrics are particularly useful for identifying market gaps and concentration risks in each DEA schedule category. Note that the primary_dosage_form output is limited to showing just one example form per schedule due to the MAX() aggregation.
    
    */