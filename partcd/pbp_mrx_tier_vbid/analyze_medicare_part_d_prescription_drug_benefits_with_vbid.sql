
-- Analyze Medicare Part D Prescription Drug Benefits with VBID

/*
Business Purpose:
This SQL query provides insights into the structure and design of Medicare Part D prescription drug benefits, with a focus on Value-Based Insurance Design (VBID) features. The analysis can help understand how plans are implementing VBID to potentially improve medication adherence and health outcomes for Medicare beneficiaries.
*/

SELECT
  -- Plan identification details
  pbp_a_hnumber AS h_number,
  pbp_a_plan_identifier AS plan_id,
  segment_id,
  bid_id,
  version,

  -- Plan characteristics
  pbp_a_plan_type AS plan_type,
  orgtype AS organization_type,
  part_d_model_demo AS part_d_model_demo,
  part_d_enhncd_cvrg_demo AS part_d_senior_savings_model,

  -- VBID features
  mrx_tier_group_id AS vbid_group_id,
  mrx_tier_id AS tier_id,
  mrx_tier_type_id AS tier_type_id,
  mrx_group_tiers_icl AS vbid_tiers_with_reduced_cost_share,
  mrx_tier_cstshr_struct_type_vb AS vbid_cost_share_structure,
  mrx_tier_cost_share_vb AS vbid_reduced_cost_share_for,
  mrx_tier_part_drugs_vb AS vbid_reduced_cost_share_for_drug_types,
  mrx_tier_part_includes_vb AS vbid_reduced_cost_share_includes,

  -- Retail cost-sharing details
  mrx_tier_rstd_copay_1m_min AS std_retail_copay_1m_min,
  mrx_tier_rstd_copay_1m_max AS std_retail_copay_1m_max,
  mrx_tier_rsstd_copay_1m_min AS std_retail_split_copay_1m_min,
  mrx_tier_rsstd_copay_1m_max AS std_retail_split_copay_1m_max,
  mrx_tier_rspfd_copay_1m_min AS pref_retail_copay_1m_min,
  mrx_tier_rspfd_copay_1m_max AS pref_retail_copay_1m_max,

  -- Mail-order cost-sharing details
  mrx_tier_mostd_copay_1m_min AS std_mail_copay_1m_min,
  mrx_tier_mostd_copay_1m_max AS std_mail_copay_1m_max,
  mrx_tier_mosstd_copay_1m_min AS std_mail_split_copay_1m_min,
  mrx_tier_mosstd_copay_1m_max AS std_mail_split_copay_1m_max,
  mrx_tier_mospfd_copay_1m_min AS pref_mail_copay_1m_min,
  mrx_tier_mospfd_copay_1m_max AS pref_mail_copay_1m_max

FROM mimi_ws_1.partcd.pbp_mrx_tier_vbid
WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.partcd.pbp_mrx_tier_vbid)
ORDER BY h_number, plan_id, segment_id;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T16:45:27.667432
    - Additional Notes: This query provides insights into the structure and design of Medicare Part D prescription drug benefits, focusing on Value-Based Insurance Design (VBID) features. It can help understand how plans are implementing VBID to potentially improve medication adherence and health outcomes for Medicare beneficiaries. The analysis is limited to the data available in the mimi_ws_1.partcd.pbp_mrx_tier_vbid table and does not include any additional plan or beneficiary-level information.
    
    */