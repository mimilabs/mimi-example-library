
-- Identifying Co-located Healthcare Providers

/*
This query demonstrates the core business value of the `mimi_ws_1.nppes.npi_to_address` table by identifying healthcare providers that are co-located based on their shared business or mailing addresses.

The ability to efficiently identify co-located providers is valuable for several reasons:
1. It can help uncover potential subsidiary and business relationships between healthcare organizations.
2. It can inform patient referral patterns and care coordination efforts.
3. It can provide insights into the geographic distribution and clustering of healthcare services.
4. It can support research on the impact of provider co-location on quality of care, patient outcomes, and healthcare costs.
*/

WITH co_located_providers AS (
  SELECT
    npi,
    name,
    entity_type_code,
    h3_r8_biz,
    h3_r10_biz,
    h3_r12_biz,
    h3_r8_mail,
    h3_r10_mail,
    h3_r12_mail
  FROM mimi_ws_1.nppes.npi_to_address
)
SELECT
  cp1.npi AS npi_1,
  cp1.name AS name_1,
  cp1.entity_type_code AS entity_type_1,
  cp2.npi AS npi_2,
  cp2.name AS name_2,
  cp2.entity_type_code AS entity_type_2,
  CASE
    WHEN cp1.h3_r8_biz = cp2.h3_r8_biz THEN 'Co-located by Business Address'
    WHEN cp1.h3_r8_mail = cp2.h3_r8_mail THEN 'Co-located by Mailing Address'
    ELSE NULL
  END AS co_location_type
FROM co_located_providers cp1
CROSS JOIN co_located_providers cp2
WHERE
  (cp1.h3_r8_biz = cp2.h3_r8_biz OR cp1.h3_r8_mail = cp2.h3_r8_mail)
  AND cp1.npi < cp2.npi
ORDER BY co_location_type DESC, npi_1, npi_2;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T16:31:53.174377
    - Additional Notes: None
    
    */