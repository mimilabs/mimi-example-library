/*
SNF Revenue Sources Analysis - Payer Mix and Revenue Composition
===============================================================

Business Purpose:
---------------
This query analyzes the revenue distribution across different payer sources for SNFs to:
- Understand the reliance on different payment sources (Medicare, Medicaid, Private Pay)
- Identify revenue diversification opportunities
- Assess market positioning and financial sustainability
- Support strategic planning for payer contract negotiations

The analysis helps stakeholders:
1. Evaluate revenue stability and payer mix optimization
2. Identify opportunities for growth in specific payer segments
3. Compare facility performance against market benchmarks
4. Support rate negotiation strategies
*/

WITH revenue_sources AS (
    -- Extract revenue data from Worksheet G-2
    SELECT 
        rpt_rec_num,
        line_num,
        itm_alphnmrc_itm_txt as revenue_amount,
        CASE 
            WHEN line_num = '1' THEN 'Medicare FFS'
            WHEN line_num = '2' THEN 'Medicare Managed Care'
            WHEN line_num = '3' THEN 'Medicaid FFS'
            WHEN line_num = '4' THEN 'Medicaid Managed Care'
            WHEN line_num = '5' THEN 'Private Insurance'
            WHEN line_num = '6' THEN 'Self Pay'
            ELSE 'Other'
        END as payer_source
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE wksht_cd = 'G200'
    AND clmn_num = '1'
    AND line_num IN ('1','2','3','4','5','6')
),

facility_totals AS (
    -- Calculate total revenue per facility
    SELECT 
        rpt_rec_num,
        SUM(CAST(revenue_amount AS DECIMAL(18,2))) as total_revenue
    FROM revenue_sources
    WHERE revenue_amount IS NOT NULL
    AND revenue_amount REGEXP '^[0-9.]+$'
    GROUP BY rpt_rec_num
)

-- Calculate revenue distribution and metrics
SELECT 
    rs.payer_source,
    COUNT(DISTINCT rs.rpt_rec_num) as facility_count,
    AVG(CAST(rs.revenue_amount AS DECIMAL(18,2))) as avg_revenue,
    AVG(CAST(rs.revenue_amount AS DECIMAL(18,2)) / ft.total_revenue * 100) as avg_pct_of_total
FROM revenue_sources rs
JOIN facility_totals ft ON rs.rpt_rec_num = ft.rpt_rec_num
WHERE rs.revenue_amount IS NOT NULL
AND rs.revenue_amount REGEXP '^[0-9.]+$'
GROUP BY rs.payer_source
ORDER BY avg_pct_of_total DESC;

/*
How the Query Works:
-------------------
1. First CTE (revenue_sources) extracts revenue data from Worksheet G-2, mapping line numbers to payer sources
2. Second CTE (facility_totals) calculates total revenue per facility
3. Final query computes key metrics:
   - Number of facilities reporting revenue for each payer
   - Average revenue per payer source
   - Average percentage of total revenue by payer

Assumptions and Limitations:
--------------------------
1. Assumes revenue data is reported consistently across facilities
2. Limited to facilities with valid numeric revenue entries
3. Does not account for seasonal variations or partial year reporting
4. Revenue categorization based on standard CMS worksheet structure

Possible Extensions:
------------------
1. Add geographic analysis by joining with provider location data
2. Trend analysis by incorporating multiple reporting periods
3. Segment analysis by facility size or ownership type
4. Correlation analysis with quality metrics
5. Market share analysis by region or service area
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:30:51.712206
    - Additional Notes: Query relies on Worksheet G-2 revenue data and assumes standardized reporting across facilities. Performance may be impacted with large datasets due to string-to-decimal conversions. Consider adding date filters for specific reporting periods if analyzing multiple years.
    
    */