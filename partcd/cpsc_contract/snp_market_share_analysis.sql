-- Medicare Advantage Special Needs Plan (SNP) Market Analysis
--
-- Business Purpose: 
--   Analyze the landscape of Special Needs Plans (SNPs) in Medicare Advantage to:
--   1. Identify organizations focusing on specialized populations
--   2. Understand market opportunities in SNP offerings
--   3. Track SNP penetration across different organization types
--   4. Examine correlation between SNP status and Part D coverage

WITH snp_summary AS (
  SELECT 
    organization_type,
    parent_organization,
    COUNT(DISTINCT contract_id) as total_contracts,
    COUNT(DISTINCT CASE WHEN snp_plan = TRUE THEN contract_id END) as snp_contracts,
    COUNT(DISTINCT CASE WHEN offers_part_d = TRUE AND snp_plan = TRUE THEN contract_id END) as snp_with_partd,
    ROUND(COUNT(DISTINCT CASE WHEN snp_plan = TRUE THEN contract_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT contract_id), 0), 1) as snp_penetration_rate
  FROM mimi_ws_1.partcd.cpsc_contract
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.partcd.cpsc_contract)
  GROUP BY organization_type, parent_organization
  HAVING COUNT(DISTINCT CASE WHEN snp_plan = TRUE THEN contract_id END) > 0
)

SELECT 
  organization_type,
  parent_organization,
  total_contracts,
  snp_contracts,
  snp_with_partd,
  snp_penetration_rate,
  ROUND(snp_with_partd * 100.0 / NULLIF(snp_contracts, 0), 1) as partd_coverage_rate
FROM snp_summary
ORDER BY snp_contracts DESC, snp_penetration_rate DESC;

-- How this query works:
-- 1. Creates a CTE that summarizes SNP metrics by organization type and parent organization
-- 2. Filters to most recent data using MAX(mimi_src_file_date)
-- 3. Calculates key metrics including SNP penetration and Part D coverage rates
-- 4. Shows only organizations that have at least one SNP contract
-- 5. Orders results by number of SNP contracts and penetration rate

-- Assumptions and Limitations:
-- 1. Assumes current data is most relevant (uses latest mimi_src_file_date)
-- 2. Does not account for contract size/enrollment
-- 3. Organizations with no SNP plans are excluded
-- 4. Does not consider geographic distribution

-- Possible Extensions:
-- 1. Add temporal analysis to track SNP growth over time
-- 2. Include geographic dimension (state/region analysis)
-- 3. Break down SNP types (C-SNP, D-SNP, I-SNP)
-- 4. Add enrollment data to weight the analysis
-- 5. Compare SNP vs non-SNP performance metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:03:09.562846
    - Additional Notes: Query focuses specifically on Special Needs Plan (SNP) market participation across different organization types and parent companies, with emphasis on Part D coverage rates. Results are filtered to show only organizations with active SNP participation, which may exclude potential market entrants or organizations that recently discontinued SNP offerings.
    
    */