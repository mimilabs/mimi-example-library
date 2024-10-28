
SELECT
  nch_clm_type_cd,
  clm_srvc_clsfctn_type_cd,
  COUNT(*) AS claim_count,
  SUM(clm_tot_chrg_amt) AS total_charges,
  AVG(clm_pmt_amt) AS avg_payment_amt
FROM mimi_ws_1.synmedpuf.outpatient
GROUP BY nch_clm_type_cd, clm_srvc_clsfctn_type_cd
ORDER BY claim_count DESC;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T18:15:34.775161
    - Additional Notes: None
    
    */