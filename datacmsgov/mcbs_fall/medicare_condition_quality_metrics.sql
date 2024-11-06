-- Medicare Beneficiary Healthcare Quality and Disease Management Analysis

-- Business Purpose:
-- Analyze the relationship between chronic conditions, quality of care metrics, and preventive services
-- to identify opportunities for improving disease management and care coordination.
-- This analysis helps health plans and providers target interventions to high-risk populations
-- and improve quality metrics that impact Star Ratings and value-based payments.

WITH chronic_conditions AS (
  -- Calculate number of chronic conditions per beneficiary
  SELECT 
    puf_id,
    surveyyr,
    CAST(CASE WHEN hlt_ochbp = 1 THEN 1 ELSE 0 END + 
         CASE WHEN hlt_ocbetes = 1 THEN 1 ELSE 0 END +
         CASE WHEN hlt_occholes = 1 THEN 1 ELSE 0 END +
         CASE WHEN hlt_ocdeprss = 1 THEN 1 ELSE 0 END +
         CASE WHEN hlt_ocemphys = 1 THEN 1 ELSE 0 END AS INT) as num_conditions
  FROM mimi_ws_1.datacmsgov.mcbs_fall
  WHERE surveyyr = 2021
),

quality_metrics AS (
  -- Calculate key quality metrics per beneficiary
  SELECT
    m.puf_id,
    m.surveyyr,
    CASE WHEN m.prv_flushot = 1 THEN 1 ELSE 0 END AS got_flu_shot,
    CASE WHEN m.prv_pneushot = 1 THEN 1 ELSE 0 END AS got_pneumonia_shot,
    CASE WHEN m.acc_mcqualty IN (1,2) THEN 1 ELSE 0 END AS satisfied_with_care
  FROM mimi_ws_1.datacmsgov.mcbs_fall m
  WHERE surveyyr = 2021
)

SELECT
  -- Segment beneficiaries by number of conditions
  CASE 
    WHEN cc.num_conditions = 0 THEN 'No Chronic Conditions'
    WHEN cc.num_conditions = 1 THEN '1 Condition'
    WHEN cc.num_conditions = 2 THEN '2 Conditions'
    ELSE '3+ Conditions'
  END AS risk_segment,
  
  -- Calculate population size and quality metrics
  COUNT(*) as beneficiary_count,
  ROUND(AVG(qm.got_flu_shot) * 100, 1) as flu_shot_pct,
  ROUND(AVG(qm.got_pneumonia_shot) * 100, 1) as pneumonia_shot_pct,
  ROUND(AVG(qm.satisfied_with_care) * 100, 1) as satisfaction_pct,
  
  -- Calculate average count of conditions for reference
  ROUND(AVG(cc.num_conditions), 1) as avg_conditions

FROM chronic_conditions cc
JOIN quality_metrics qm 
  ON cc.puf_id = qm.puf_id 
  AND cc.surveyyr = qm.surveyyr

GROUP BY 
  CASE 
    WHEN cc.num_conditions = 0 THEN 'No Chronic Conditions'
    WHEN cc.num_conditions = 1 THEN '1 Condition' 
    WHEN cc.num_conditions = 2 THEN '2 Conditions'
    ELSE '3+ Conditions'
  END
ORDER BY avg_conditions;

-- How this works:
-- 1. First CTE calculates number of key chronic conditions per beneficiary
-- 2. Second CTE flags key quality metrics around preventive care and satisfaction
-- 3. Main query segments beneficiaries by condition count and calculates metrics
-- 4. Results show how quality metrics vary by disease burden

-- Assumptions and Limitations:
-- - Analysis limited to 5 major chronic conditions
-- - 2021 data only for consistency
-- - Simple satisfied/not satisfied categorization
-- - No risk adjustment or demographic controls
-- - Limited to survey respondents (may not be representative)

-- Possible Extensions:
-- 1. Add demographic breakdowns (age, gender, race)
-- 2. Include additional conditions and quality metrics
-- 3. Trend analysis over multiple years
-- 4. Add cost and utilization metrics
-- 5. Compare Medicare Advantage vs Traditional Medicare
-- 6. Add geographic analysis
-- 7. Include medication adherence metrics
-- 8. Analyze care coordination measures

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:15:01.693338
    - Additional Notes: Query focuses on quality of care metrics stratified by chronic condition burden. Results may be affected by survey response rates and self-reported conditions. Consider adding claims-based condition flags for more comprehensive analysis.
    
    */