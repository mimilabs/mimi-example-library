-- Title: NHANES Cigarette Brand Preference and Nicotine Exposure Analysis
--
-- Business Purpose:
-- This query analyzes cigarette brand preferences and associated nicotine exposure patterns to:
-- 1. Identify most common cigarette brands and their characteristics
-- 2. Understand menthol vs non-menthol preferences
-- 3. Assess typical nicotine content exposure
-- 4. Support tobacco control and public health initiatives
--
-- The insights can inform:
-- - Product regulation strategies
-- - Targeted cessation programs
-- - Health equity initiatives (especially regarding menthol)
-- - Public health communications

WITH brand_metrics AS (
  SELECT 
    -- Brand characteristics
    smd100br as brand,
    smd100mn as menthol_status,
    smd100ni as nicotine_content,
    
    -- Consumption metrics
    COUNT(DISTINCT seqn) as user_count,
    AVG(smd650) as avg_daily_cigarettes,
    
    -- Calculate relative market share
    COUNT(DISTINCT seqn) * 100.0 / 
      SUM(COUNT(DISTINCT seqn)) OVER () as market_share_pct

  FROM mimi_ws_1.cdc.nhanes_qre_smoking_cigarette_use
  WHERE 
    -- Focus on current smokers
    smq040 = 1 
    AND smd100br IS NOT NULL
    AND smd650 IS NOT NULL
  GROUP BY 
    smd100br,
    smd100mn,
    smd100ni
)

SELECT
  brand,
  menthol_status,
  nicotine_content,
  user_count,
  ROUND(avg_daily_cigarettes, 1) as avg_daily_cigarettes,
  ROUND(market_share_pct, 1) as market_share_pct,
  
  -- Calculate estimated daily nicotine exposure
  ROUND(nicotine_content * avg_daily_cigarettes, 2) as est_daily_nicotine_mg
  
FROM brand_metrics
WHERE market_share_pct >= 1.0  -- Focus on brands with at least 1% market share
ORDER BY market_share_pct DESC
LIMIT 20

/*
How the Query Works:
1. Creates brand_metrics CTE to aggregate key brand-level statistics
2. Focuses on current smokers using smq040 = 1
3. Calculates market share and average consumption patterns
4. Estimates daily nicotine exposure based on cigarette count and nicotine content
5. Filters to significant brands (>1% market share) and shows top 20

Assumptions & Limitations:
- Relies on accurate self-reporting of cigarette consumption
- Assumes consistent nicotine content within brands
- May not capture all product variants
- Market share is based on survey sample, not actual sales data

Possible Extensions:
1. Add demographic breakdowns by age/gender/ethnicity
2. Trend analysis across survey years
3. Geographic variation analysis
4. Correlation with quit attempts or success rates
5. Price sensitivity analysis if cost data available
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:20:30.872504
    - Additional Notes: Query focuses on brand-level analysis and nicotine exposure patterns. Requires smq040 (current smoking status), smd100br (brand), and smd650 (daily cigarette count) fields to be populated for meaningful results. Market share calculations are based on survey respondents rather than actual sales data, which may not perfectly reflect true market distribution.
    
    */