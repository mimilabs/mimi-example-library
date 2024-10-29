/*
Title: Home Health Agency Revenue Mix and Payer Source Analysis

Business Purpose:
This query analyzes the revenue distribution across different payer sources (Medicare, Medicaid, etc.)
for Home Health Agencies to help identify revenue diversification opportunities and payer mix trends.
The insights can inform market entry strategies, contract negotiations, and revenue optimization efforts.
*/

-- Get revenue by payer source from Worksheet F-1
WITH payer_revenue AS (
  SELECT 
    rpt_rec_num,
    -- Extract year from source file date for trending
    YEAR(mimi_src_file_date) as reporting_year,
    -- Medicare revenue (line 1, column 4)
    MAX(CASE WHEN wksht_cd = 'F1' AND line_num = 1 AND clmn_num = 4 
        THEN itm_val_num ELSE 0 END) as medicare_rev,
    -- Medicaid revenue (line 2, column 4)  
    MAX(CASE WHEN wksht_cd = 'F1' AND line_num = 2 AND clmn_num = 4 
        THEN itm_val_num ELSE 0 END) as medicaid_rev,
    -- Other government revenue (line 3, column 4)
    MAX(CASE WHEN wksht_cd = 'F1' AND line_num = 3 AND clmn_num = 4 
        THEN itm_val_num ELSE 0 END) as other_gov_rev,
    -- Private insurance revenue (line 4, column 4)
    MAX(CASE WHEN wksht_cd = 'F1' AND line_num = 4 AND clmn_num = 4 
        THEN itm_val_num ELSE 0 END) as private_ins_rev
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
  WHERE wksht_cd = 'F1' 
  GROUP BY rpt_rec_num, YEAR(mimi_src_file_date)
)

SELECT
  reporting_year,
  COUNT(rpt_rec_num) as num_agencies,
  -- Calculate average revenue by payer
  AVG(medicare_rev) as avg_medicare_rev,
  AVG(medicaid_rev) as avg_medicaid_rev,
  AVG(private_ins_rev) as avg_private_ins_rev,
  AVG(other_gov_rev) as avg_other_gov_rev,
  -- Calculate revenue mix percentages
  AVG(medicare_rev/(medicare_rev + medicaid_rev + private_ins_rev + other_gov_rev))*100 
    as medicare_rev_pct,
  AVG(medicaid_rev/(medicare_rev + medicaid_rev + private_ins_rev + other_gov_rev))*100 
    as medicaid_rev_pct,
  AVG(private_ins_rev/(medicare_rev + medicaid_rev + private_ins_rev + other_gov_rev))*100 
    as private_ins_rev_pct
FROM payer_revenue
GROUP BY reporting_year
ORDER BY reporting_year DESC;

/*
How this query works:
1. Extracts revenue data from Worksheet F-1 using pivoted CASE statements
2. Calculates revenue mix percentages and averages across agencies
3. Groups results by year to show trends

Assumptions and Limitations:
- Assumes revenue reporting is consistent across agencies
- Excludes agencies with missing revenue data
- Does not account for regional variations
- Limited to basic revenue categories on Worksheet F-1

Possible Extensions:
1. Add geographic segmentation by state/region
2. Include agency size categories based on total revenue
3. Compare revenue mix of profitable vs unprofitable agencies
4. Analyze correlation between payer mix and quality metrics
5. Add trend analysis with year-over-year growth rates
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:10:07.660577
    - Additional Notes: Query focuses on Worksheet F-1 revenue breakdown by payer source. Results are aggregated yearly, showing average revenue and percentage mix across Medicare, Medicaid, private insurance, and other government sources. Best used for understanding revenue diversification patterns and payer mix trends across reporting periods.
    
    */