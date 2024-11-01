-- fda_rare_disease_drug_analysis.sql

-- Business Purpose:
-- - Analyze drug products approved for rare diseases and orphan conditions
-- - Identify pharmaceutical companies focused on rare disease treatments
-- - Track approval trends in the rare disease drug market
-- - Support strategic planning for specialty pharma and biotech investments

-- Core Query with Rare Disease Drug Analysis
WITH rare_disease_drugs AS (
  SELECT 
    DISTINCT ingredient,
    trade_name,
    applicant_full_name,
    approval_date,
    appl_type,
    df_route,
    strength
  FROM mimi_ws_1.fda.orangebook_products
  WHERE 
    -- Filter for New Drug Applications which are more common for rare diseases
    appl_type = 'N' 
    -- Use recent approval dates to focus on current market
    AND approval_date >= '2010-01-01'
    -- Focus on prescription drugs
    AND type = 'RX'
),

company_metrics AS (
  SELECT 
    applicant_full_name,
    COUNT(DISTINCT trade_name) as drug_count,
    MIN(approval_date) as first_approval,
    MAX(approval_date) as latest_approval
  FROM rare_disease_drugs
  GROUP BY applicant_full_name
)

SELECT 
  cm.applicant_full_name,
  cm.drug_count,
  cm.first_approval,
  cm.latest_approval,
  CONCAT_WS(', ', COLLECT_SET(rd.trade_name)) as drug_portfolio
FROM company_metrics cm
JOIN rare_disease_drugs rd 
  ON cm.applicant_full_name = rd.applicant_full_name
WHERE cm.drug_count >= 3  -- Focus on companies with significant presence
GROUP BY 
  cm.applicant_full_name,
  cm.drug_count,
  cm.first_approval,
  cm.latest_approval
ORDER BY cm.drug_count DESC, cm.latest_approval DESC;

-- How the Query Works:
-- 1. First CTE filters for likely rare disease drugs using NDA applications
-- 2. Second CTE calculates key metrics per company
-- 3. Final query joins the data to show company portfolios
-- 4. Results show companies with 3+ drugs, ordered by portfolio size

-- Assumptions and Limitations:
-- - Uses NDA applications as a proxy for rare disease drugs
-- - Limited to drugs approved since 2010
-- - May include some non-rare disease drugs
-- - Does not account for mergers/acquisitions
-- - Company names may have variations

-- Possible Extensions:
-- 1. Add therapeutic category analysis
-- 2. Include patent expiration analysis
-- 3. Add market exclusivity period tracking
-- 4. Incorporate dosage form analysis
-- 5. Add approval timeline analysis
-- 6. Compare with generic entry patterns
-- 7. Add geographical market presence
-- 8. Include pricing/reimbursement data if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:54:03.030203
    - Additional Notes: Query focuses on identifying companies with significant rare disease drug portfolios by using NDA applications as a proxy. The drug_count >= 3 filter helps focus on established players in the rare disease space. Results are limited to approvals from 2010 onwards for contemporary market analysis.
    
    */