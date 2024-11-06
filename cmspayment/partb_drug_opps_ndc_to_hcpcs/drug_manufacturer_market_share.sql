-- drug_manufacturer_market_analysis.sql
-- Business Purpose: Analyze drug manufacturer market presence and product diversity across therapeutic categories
-- to identify market leaders, concentration patterns, and potential strategic opportunities.
-- This insight helps inform market entry strategies, competitive analysis, and partnership decisions.

WITH manufacturer_stats AS (
  -- Calculate key metrics per manufacturer
  SELECT 
    labeler_name,
    COUNT(DISTINCT hcpcs_code) as unique_hcpcs,
    COUNT(DISTINCT ndc) as unique_ndcs,
    COUNT(DISTINCT drug_name) as unique_drugs
  FROM mimi_ws_1.cmspayment.partb_drug_opps_ndc_to_hcpcs
  WHERE labeler_name IS NOT NULL 
  GROUP BY labeler_name
),
ranked_manufacturers AS (
  -- Rank manufacturers by product diversity
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY unique_drugs DESC) as mfr_rank,
    ROUND(unique_ndcs::DECIMAL / unique_drugs, 2) as ndc_per_drug_ratio
  FROM manufacturer_stats
)
SELECT 
  labeler_name as manufacturer,
  unique_hcpcs as hcpcs_codes,
  unique_ndcs as ndc_codes,
  unique_drugs as drug_products,
  ndc_per_drug_ratio as formulation_diversity,
  CASE 
    WHEN mfr_rank <= 10 THEN 'Top 10'
    WHEN mfr_rank <= 25 THEN 'Top 11-25'
    ELSE 'Other'
  END as market_position
FROM ranked_manufacturers
WHERE unique_drugs >= 3  -- Focus on established manufacturers
ORDER BY unique_drugs DESC, ndc_per_drug_ratio DESC
LIMIT 50;

-- How this query works:
-- 1. First CTE aggregates key product metrics by manufacturer
-- 2. Second CTE adds ranking and calculates NDC/drug ratio as a measure of formulation diversity
-- 3. Final select formats output with meaningful business categories
-- 4. Results limited to manufacturers with meaningful presence (3+ drugs)

-- Assumptions and Limitations:
-- - Assumes labeler_name is standardized and clean
-- - Does not account for mergers/acquisitions or parent-subsidiary relationships
-- - Market presence based on unique products, not revenue or volume
-- - Limited to drugs in the OPPS system

-- Possible Extensions:
-- 1. Add therapeutic category analysis by parsing HCPCS descriptions
-- 2. Include trending over time using mimi_src_file_date
-- 3. Add package size/billing unit analysis for manufacturing scale insights
-- 4. Compare market concentration across different drug categories
-- 5. Add revenue potential analysis by incorporating pricing data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:11:29.358034
    - Additional Notes: Query focuses on manufacturer market presence metrics but excludes smaller players with less than 3 drugs. Consider adjusting the threshold (unique_drugs >= 3) based on specific analysis needs. The formulation_diversity ratio helps identify manufacturers with multiple formulations per drug, which could indicate technical sophistication or market segmentation strategies.
    
    */