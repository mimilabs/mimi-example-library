-- medicare_behavioral_health_insights.sql
-- Business Purpose: Analyze behavioral health provider distributions and utilization patterns to inform
-- network adequacy and care delivery strategies. Behavioral health is a critical focus area given rising 
-- mental health needs and provider shortages.

WITH bh_providers AS (
  -- Filter to behavioral health providers and most recent year
  SELECT 
    rndrng_prvdr_type,
    rndrng_prvdr_state_abrvtn,
    rndrng_prvdr_ruca_desc,
    tot_benes,
    bene_cc_bh_anxiety_v1_pct,
    bene_cc_bh_depress_v1_pct,
    bene_cc_bh_bipolar_v1_pct,
    bene_cc_bh_alcohol_drug_v1_pct,
    bene_dual_cnt / NULLIF(tot_benes, 0) * 100 as dual_eligible_pct,
    bene_avg_risk_scre
  FROM mimi_ws_1.datacmsgov.mupphy_prvdr
  WHERE rndrng_prvdr_type IN ('Psychiatry', 'Clinical Psychologist', 'Clinical Social Worker')
    AND mimi_src_file_date = '2022-12-31' -- Most recent year
)

SELECT
  rndrng_prvdr_type,
  rndrng_prvdr_state_abrvtn,
  COUNT(*) as provider_cnt,
  -- Access metrics
  ROUND(AVG(tot_benes),1) as avg_benes_per_provider,
  ROUND(SUM(CASE WHEN rndrng_prvdr_ruca_desc LIKE '%Rural%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as rural_provider_pct,
  
  -- Patient complexity metrics
  ROUND(AVG(dual_eligible_pct),1) as avg_dual_eligible_pct,
  ROUND(AVG(bene_avg_risk_scre),2) as avg_risk_score,
  
  -- Condition prevalence 
  ROUND(AVG(bene_cc_bh_anxiety_v1_pct),1) as avg_anxiety_pct,
  ROUND(AVG(bene_cc_bh_depress_v1_pct),1) as avg_depression_pct,
  ROUND(AVG(bene_cc_bh_bipolar_v1_pct),1) as avg_bipolar_pct,
  ROUND(AVG(bene_cc_bh_alcohol_drug_v1_pct),1) as avg_sud_pct

FROM bh_providers
GROUP BY 1,2
HAVING provider_cnt >= 10 -- Filter to protect privacy
ORDER BY rndrng_prvdr_type, provider_cnt DESC;

/* How this query works:
1. Filters to behavioral health provider types and most recent year
2. Calculates key metrics around access (provider counts, rurality), patient complexity (dual status, risk scores)
   and condition prevalence
3. Aggregates results by provider type and state
4. Applies privacy threshold of minimum 10 providers

Key assumptions and limitations:
- Limited to Medicare FFS beneficiaries
- Provider specialty based on plurality of services
- Condition percentages based on claims algorithms
- State-level may mask local market variation
- Rural/urban based on provider location not patient

Possible extensions:
1. Add year-over-year trend analysis
2. Include cost and utilization metrics
3. Analyze by more granular geography
4. Compare to commercial benchmarks
5. Add demographic breakdowns
6. Link to quality metrics
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:43:34.437135
    - Additional Notes: The query provides state-level behavioral health provider network analysis with focus on access metrics and patient complexity. Requires at least 10 providers per state-specialty group for privacy protection. Best used for strategic planning around behavioral health network adequacy and identifying potential access gaps.
    
    */