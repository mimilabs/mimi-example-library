/* 
ACO Financial Performance Analysis 

Purpose: Analyze the key financial and quality metrics of Medicare Shared Savings Program ACOs
to identify high-performing organizations and success factors.

This query provides insights into:
- Generated savings/losses and earned shared savings
- Quality performance scores
- Risk model participation
- Patient demographics and utilization patterns

Business Value:
- Identify characteristics of successful ACOs to inform program improvements
- Support strategic planning for ACO participation
- Guide quality improvement initiatives
*/

WITH aco_performance AS (
  SELECT 
    aco_name,
    performance_year_end,
    current_track,
    risk_model,
    n_ab as assigned_beneficiaries,
    round(gen_save_loss/1000000,2) as generated_savings_mm,
    round(earn_save_loss/1000000,2) as earned_savings_mm,
    qual_score as quality_score,
    rev_exp_cat as revenue_category
  FROM mimi_ws_1.datacmsgov.acoresults
  WHERE performance_year_end >= '2020-12-31' -- Focus on recent performance
)

SELECT
  revenue_category,
  risk_model,
  count(distinct aco_name) as num_acos,
  round(avg(assigned_beneficiaries),0) as avg_assigned_beneficiaries,
  round(avg(generated_savings_mm),2) as avg_generated_savings_mm,
  round(avg(earned_savings_mm),2) as avg_earned_savings_mm,
  round(avg(quality_score),1) as avg_quality_score,
  round(sum(earned_savings_mm),2) as total_earned_savings_mm
FROM aco_performance
GROUP BY revenue_category, risk_model
ORDER BY revenue_category, risk_model;

/*
How This Query Works:
1. Creates CTE with key performance metrics at ACO level
2. Aggregates results by revenue category and risk model
3. Calculates averages and totals for key metrics

Assumptions & Limitations:
- Focuses on recent performance (2020+)
- Assumes quality scores are comparable across years
- Dollar amounts converted to millions for readability
- Limited to high-level revenue/risk model segments

Possible Extensions:
1. Add year-over-year trend analysis
2. Include patient demographic factors
3. Add quality measure details
4. Analyze regional variations
5. Add advanced statistical measures (e.g., correlation between quality and savings)

Sample Research Questions Answered:
1. Which ACO types generate the most savings?
2. How does quality correlate with financial performance?
3. What is the relationship between ACO size and success?
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:16:37.248062
    - Additional Notes: Query focuses on high-level financial metrics and may need memory optimization if analyzing very large datasets. Performance metrics are rounded for readability, which may affect precision in detailed analysis. Consider filtering specific performance years if analyzing a particular time period.
    
    */