-- Title: NHANES Tobacco Usage Intensity and Consumption Analysis

-- Business Purpose:
-- - Calculate average daily cigarette consumption for active smokers
-- - Identify heavy vs light tobacco users to support targeted interventions
-- - Provide baseline metrics for healthcare resource planning and risk assessment
-- - Enable cost modeling for smoking-related healthcare expenses

-- Main Query
WITH active_smokers AS (
  SELECT
    seqn,
    CASE 
      WHEN smq710 = 5 THEN 'Daily'
      WHEN smq710 >= 3 THEN 'Frequent' 
      WHEN smq710 > 0 THEN 'Occasional'
      ELSE 'Non-Smoker'
    END AS smoking_frequency,
    smq710 AS days_smoked_past5,
    smq720 AS cigs_per_day,
    -- Calculate average daily consumption
    (smq710 * smq720) / 5.0 AS avg_daily_cigs
  FROM mimi_ws_1.cdc.nhanes_qre_smoking_recent_tobacco_use
  WHERE smq710 > 0 
    AND smq720 > 0
)

SELECT
  smoking_frequency,
  COUNT(*) as user_count,
  ROUND(AVG(cigs_per_day), 1) as avg_cigs_when_smoking,
  ROUND(AVG(avg_daily_cigs), 1) as avg_cigs_per_day,
  -- Define consumption intensity tiers
  SUM(CASE WHEN avg_daily_cigs >= 20 THEN 1 ELSE 0 END) as heavy_users,
  SUM(CASE WHEN avg_daily_cigs < 20 AND avg_daily_cigs >= 10 THEN 1 ELSE 0 END) as moderate_users,
  SUM(CASE WHEN avg_daily_cigs < 10 THEN 1 ELSE 0 END) as light_users
FROM active_smokers
GROUP BY smoking_frequency
ORDER BY 
  CASE smoking_frequency 
    WHEN 'Daily' THEN 1
    WHEN 'Frequent' THEN 2
    WHEN 'Occasional' THEN 3
    ELSE 4
  END;

-- How it works:
-- 1. Creates a CTE identifying active smokers and their consumption patterns
-- 2. Calculates true average daily consumption accounting for non-smoking days
-- 3. Segments users into frequency categories (Daily/Frequent/Occasional)
-- 4. Provides summary metrics including intensity tiers based on consumption

-- Assumptions and Limitations:
-- - Assumes reported cigarette counts are accurate
-- - Limited to past 5 days of data which may not represent long-term patterns
-- - Does not account for seasonal variations in smoking behavior
-- - Excludes records with missing/zero values for days smoked or cigarettes per day

-- Possible Extensions:
-- 1. Add demographic breakdowns (would need to join with demographics table)
-- 2. Include cost analysis using average cigarette pack prices
-- 3. Expand to include other forms of tobacco products
-- 4. Add year-over-year trend analysis
-- 5. Calculate estimated annual healthcare costs based on consumption intensity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:28:24.832891
    - Additional Notes: Query segments smokers into usage tiers and calculates true daily consumption rates adjusted for non-smoking days. Results can be used for healthcare cost modeling and intervention planning. Note that the 5-day window may not capture long-term usage patterns.
    
    */