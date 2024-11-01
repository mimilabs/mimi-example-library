-- revenue_source_mix_analysis.sql
--
-- Purpose: Analyze the revenue source distribution across hospitals to understand the payer mix
-- and identify revenue diversification opportunities.
--
-- Business Value: 
-- - Understand revenue composition trends to optimize payer contracting strategies
-- - Identify hospitals with successful revenue diversification for best practice sharing
-- - Support strategic planning around service line development
-- - Guide investment decisions based on payer mix patterns

-- Main Query
WITH revenue_sources AS (
    SELECT 
        rpt_rec_num,
        mimi_src_file_date,
        CASE 
            WHEN wksht_cd = 'G3' AND line_num = '1' AND clmn_num = '1' THEN 'Medicare'
            WHEN wksht_cd = 'G3' AND line_num = '2' AND clmn_num = '1' THEN 'Medicaid'
            WHEN wksht_cd = 'G3' AND line_num = '3' AND clmn_num = '1' THEN 'Private Insurance'
            ELSE 'Other'
        END AS payer_type,
        itm_alphnmrc_itm_txt as revenue_amount
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_alpha
    WHERE wksht_cd = 'G3' 
    AND line_num IN ('1', '2', '3')
    AND clmn_num = '1'
)

SELECT 
    EXTRACT(YEAR FROM mimi_src_file_date) as report_year,
    payer_type,
    COUNT(DISTINCT rpt_rec_num) as hospital_count,
    AVG(CAST(revenue_amount AS DECIMAL(18,2))) as avg_revenue,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY CAST(revenue_amount AS DECIMAL(18,2))) as median_revenue
FROM revenue_sources
WHERE revenue_amount IS NOT NULL
  AND revenue_amount REGEXP '^[0-9]+\.?[0-9]*$' -- Ensure valid numeric values
GROUP BY 
    EXTRACT(YEAR FROM mimi_src_file_date),
    payer_type
ORDER BY 
    report_year DESC,
    payer_type;

-- How it works:
-- 1. Creates a CTE to classify revenue sources based on worksheet G3 line items
-- 2. Extracts year from file date for temporal analysis
-- 3. Calculates key metrics including hospital count and revenue statistics
-- 4. Filters for valid numeric revenue values
-- 5. Groups results by year and payer type for trend analysis

-- Assumptions and Limitations:
-- - Assumes worksheet G3 contains standardized revenue reporting across hospitals
-- - Limited to primary revenue sources (Medicare, Medicaid, Private Insurance)
-- - Depends on consistent reporting practices across facilities
-- - May not capture all revenue sources or special payment arrangements
-- - Revenue amounts should be validated for reporting consistency

-- Possible Extensions:
-- 1. Add geographic segmentation by incorporating facility location data
-- 2. Include hospital characteristics (size, type, ownership) for deeper analysis
-- 3. Calculate year-over-year growth rates and market share trends
-- 4. Add service line revenue breakdown within each payer category
-- 5. Incorporate quality metrics to analyze revenue-quality relationships
-- 6. Add seasonal revenue pattern analysis
-- 7. Include cost data to calculate margin analysis by payer

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:20:35.542605
    - Additional Notes: Query focuses on Worksheet G3 revenue data and requires proper numeric formatting in itm_alphnmrc_itm_txt field. May need adjustment based on specific revenue code mappings and hospital reporting patterns. Consider validating revenue amounts against total revenue calculations for accuracy.
    
    */