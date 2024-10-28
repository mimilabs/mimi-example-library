
-- Analyzing Medicare Part B Drug Pricing

-- This query provides insights into the pricing and reimbursement of Medicare Part B drugs, which are essential for understanding the costs associated with these treatments.

-- The key business value of this table is to enable analysis of:
-- 1. Pricing trends for specific Part B drugs over time
-- 2. Relationships between the Average Sales Price (ASP) and the Medicare payment limit
-- 3. Variations in the coinsurance percentage for different Part B drugs
-- 4. Pricing differences among drug categories (e.g., vaccines, blood products, clotting factors)
-- This information can help policymakers, healthcare providers, and researchers make more informed decisions about Part B drug utilization and reimbursement.

SELECT
  hcpcs_code,
  short_description,
  hcpcs_code_dosage,
  payment_limit,
  coinsurance_percentage,
  vaccine_awp_pct,
  vaccine_limit,
  blood_awp_pct,
  blood_limit,
  clotting_factor,
  infusion_awp_pct,
  dme_infusion_limit,
  clotting_factor_fee,
  mimi_src_file_date
FROM mimi_ws_1.cmspayment.partb_drug_asp_pricing
ORDER BY mimi_src_file_date DESC
LIMIT 10;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T16:39:09.224567
    - Additional Notes: None
    
    */