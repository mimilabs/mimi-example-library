
-- Analyze Medicare Durable Medical Equipment Utilization and Spending by Supplier

/*
Business Purpose:
The `mimi_ws_1.datacmsgov.mupdme_suphpr` table provides valuable insights into the utilization and spending patterns for Medicare Durable Medical Equipment (DME), Devices, and Supplies. By analyzing this data, we can:

1. Identify the top suppliers for specific HCPCS codes based on total Medicare allowed amount.
2. Understand how the average submitted charges and Medicare payments vary across different suppliers for a particular HCPCS code.
3. Discover which HCPCS codes have the highest utilization and spending for a given supplier.
4. Explore any geographic variations in the utilization and spending patterns for specific HCPCS codes or suppliers.
5. Assess the ratio of Medicare allowed amount to submitted charges across different suppliers and HCPCS codes, which can provide insights into the factors influencing these variations.

This analysis can help inform strategic decision-making, procurement, and reimbursement policies related to Medicare DME, Devices, and Supplies.
*/

-- 1. Find the top 10 suppliers by total Medicare allowed amount for a specific HCPCS code
WITH hcpcs_summary AS (
  SELECT
    hcpcs_cd,
    suplr_npi,
    suplr_prvdr_last_name_org,
    SUM(tot_suplr_srvcs) AS total_services,
    SUM(avg_suplr_mdcr_alowd_amt * tot_suplr_srvcs) AS total_medicare_allowed
  FROM mimi_ws_1.datacmsgov.mupdme_suphpr
  WHERE hcpcs_cd = 'E0601'  -- Replace with the desired HCPCS code
  GROUP BY hcpcs_cd, suplr_npi, suplr_prvdr_last_name_org
  ORDER BY total_medicare_allowed DESC
  LIMIT 10
)
SELECT
  hcpcs_cd,
  suplr_prvdr_last_name_org AS supplier_name,
  total_services,
  total_medicare_allowed,
  CAST(total_medicare_allowed / total_services AS DECIMAL(10,2)) AS avg_medicare_allowed_per_service
FROM hcpcs_summary
ORDER BY total_medicare_allowed DESC;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T19:26:27.040104
    - Additional Notes: None
    
    */