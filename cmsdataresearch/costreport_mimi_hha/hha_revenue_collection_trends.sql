-- TITLE: Home Health Agency Revenue Cycle Analysis

-- BUSINESS PURPOSE:
-- Analyze the revenue cycle health of home health agencies to identify:
-- - Collection efficiency by comparing gross to net revenue
-- - Bad debt trends and write-off patterns  
-- - Payment realization across Medicare, Medicaid and other payers
-- - Organizations with concerning revenue trends that may need intervention

SELECT
    fiscal_year_end_date,
    hha_name,
    state_code,
    
    -- Revenue collection efficiency metrics
    gross_patient_revenues_total as gross_revenue,
    net_patient_revenues_line_1_minus_line_2_total as net_revenue,
    ROUND(net_patient_revenues_line_1_minus_line_2_total / 
          NULLIF(gross_patient_revenues_total, 0) * 100, 1) as collection_rate_pct,
    
    -- Program-wise revenue realization
    gross_patient_revenues_title_xviii_medicare as medicare_gross,
    net_patient_revenues_line_1_minus_line_2_xviii_medicare as medicare_net,
    gross_patient_revenues_title_xix_medicaid as medicaid_gross,
    net_patient_revenues_line_1_minus_line_2_xix_medicaid as medicaid_net,
    
    -- Bad debt metrics
    allowable_bad_debts,
    adjusted_reimbursable_bad_debts,
    ROUND(allowable_bad_debts / 
          NULLIF(gross_patient_revenues_total, 0) * 100, 1) as bad_debt_pct

FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hha

-- Focus on recent complete fiscal years
WHERE fiscal_year_end_date >= '2018-01-01'
  AND gross_patient_revenues_total > 0

-- Order by concerning collection rates
ORDER BY collection_rate_pct ASC, 
         gross_patient_revenues_total DESC;

-- HOW IT WORKS:
-- 1. Calculates collection rate as net revenue / gross revenue
-- 2. Shows gross vs net revenue breakdowns by key programs
-- 3. Analyzes bad debt as % of gross revenue
-- 4. Orders results to highlight agencies with concerning collection rates

-- ASSUMPTIONS & LIMITATIONS:
-- - Assumes gross revenue > 0 for valid percentage calculations
-- - Limited to recent fiscal years for relevance
-- - Does not account for differences in payer mix
-- - Bad debt write-off policies may vary by organization

-- POSSIBLE EXTENSIONS:
-- 1. Add year-over-year trend analysis of collection rates
-- 2. Include service mix factors that may impact collections
-- 3. Add peer group comparisons by state/size
-- 4. Incorporate aging of receivables analysis
-- 5. Flag statistical outliers in collection patterns
-- 6. Add operating margin impact analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:52:33.587155
    - Additional Notes: Query prioritizes agencies with collection issues by calculating collection efficiency ratios. Consider adjusting the fiscal_year_end_date filter based on available data currency. Collection rate percentages may need validation for extreme outliers (very low or >100%).
    
    */