-- cbsa_zip_address_composition.sql

-- Business Purpose: Analyze the composition of different address types (residential, business, other)
-- within CBSA-ZIP combinations to support market segmentation, service delivery planning,
-- and targeted outreach strategies. This helps organizations understand the mix of address 
-- types in different geographic areas for better resource allocation and market positioning.

WITH address_composition AS (
  SELECT 
    cbsa,
    usps_zip_pref_state as state,
    COUNT(DISTINCT zip) as zip_count,
    ROUND(AVG(res_ratio * 100), 2) as avg_residential_pct,
    ROUND(AVG(bus_ratio * 100), 2) as avg_business_pct,
    ROUND(AVG(oth_ratio * 100), 2) as avg_other_pct
  FROM mimi_ws_1.huduser.cbsa_to_zip_otm
  WHERE cbsa != '99999' -- Exclude non-CBSA areas
  GROUP BY cbsa, state
),

ranked_areas AS (
  SELECT 
    *,
    RANK() OVER (ORDER BY avg_residential_pct DESC) as residential_rank,
    RANK() OVER (ORDER BY avg_business_pct DESC) as business_rank
  FROM address_composition
  WHERE zip_count >= 5 -- Focus on CBSAs with meaningful ZIP coverage
)

SELECT 
  cbsa,
  state,
  zip_count,
  avg_residential_pct,
  avg_business_pct,
  avg_other_pct,
  CASE 
    WHEN avg_residential_pct >= 70 THEN 'Primarily Residential'
    WHEN avg_business_pct >= 30 THEN 'Business Hub'
    ELSE 'Mixed Use'
  END as area_classification
FROM ranked_areas
ORDER BY avg_residential_pct DESC, zip_count DESC
LIMIT 100;

/* How this query works:
1. First CTE (address_composition) aggregates address type ratios by CBSA and state
2. Second CTE (ranked_areas) adds rankings based on residential and business percentages
3. Final SELECT adds classification based on composition thresholds
4. Results show top 100 areas by residential percentage with meaningful ZIP coverage

Assumptions and limitations:
- Excludes CBSAs with code '99999' (non-CBSA areas)
- Requires minimum 5 ZIP codes per CBSA for meaningful analysis
- Classifications are based on simple thresholds that may need adjustment
- Current snapshot only (temporal analysis not included)

Possible extensions:
1. Add temporal analysis by incorporating mimi_src_file_date
2. Create more sophisticated classification logic using multiple ratio thresholds
3. Add population data overlay for per-capita analysis
4. Include geographic clustering analysis
5. Add year-over-year comparison of address type compositions
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:39:54.117133
    - Additional Notes: The query effectively analyzes address type distribution patterns but should be adjusted if the 5 ZIP minimum threshold or 70%/30% classification thresholds need to align with specific business requirements. Consider local market conditions when interpreting the area_classification results.
    
    */