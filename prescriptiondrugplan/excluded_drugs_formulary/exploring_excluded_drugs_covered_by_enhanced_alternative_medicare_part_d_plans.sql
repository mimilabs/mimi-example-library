
-- Exploring Excluded Drugs Covered by Enhanced Alternative Medicare Part D Plans

/*
Business Purpose:
The `excluded_drugs_formulary` table provides valuable insights into the supplemental drug coverage offered by enhanced alternative Medicare Part D plans. By analyzing this data, we can understand the types of excluded drugs that these plans choose to cover, the cost-sharing structures, and any utilization management restrictions in place. This information can inform decision-making for Medicare beneficiaries, plan administrators, and policymakers.
*/

/*
Main Query:
This query explores the top 10 most commonly covered excluded drugs, along with their cost-sharing tiers and any quantity limit restrictions.
*/

SELECT
  rxcui,
  COUNT(*) AS plan_count,
  MAX(tier) AS max_tier,
  MAX(quantity_limit_yn) AS has_quantity_limit
FROM
  mimi_ws_1.prescriptiondrugplan.excluded_drugs_formulary
GROUP BY
  rxcui
ORDER BY
  plan_count DESC
LIMIT 10;

/*
How the Query Works:
1. The query selects the RXCUI (RxNorm concept unique identifier), which represents the drug product, and groups the results by RXCUI.
2. The `COUNT(*)` aggregates the number of plans that cover each excluded drug, giving us the plan_count.
3. The `MAX(tier)` and `MAX(quantity_limit_yn)` functions capture the maximum tier and whether a quantity limit is in place for each drug, respectively.
4. The results are ordered by the plan_count in descending order, and the top 10 rows are returned.

Assumptions and Limitations:
- This query assumes that the `excluded_drugs_formulary` table contains accurate and up-to-date information on the covered excluded drugs, cost-sharing tiers, and quantity limit restrictions.
- The data is limited to enhanced alternative Medicare Part D plans and does not represent the overall formulary coverage across all Part D plans.
- The query does not consider other factors that may influence the coverage of excluded drugs, such as geographic region, plan performance, or beneficiary demographics.

Possible Extensions:
1. Analyze the regional variations in the coverage of excluded drugs by enhanced alternative plans.
2. Investigate the relationship between the coverage of excluded drugs and plan performance metrics, such as beneficiary satisfaction or plan ratings.
3. Explore the differences in beneficiary costs for excluded drugs compared to drugs in the basic formulary.
4. Identify any patterns or trends in the types of drugs that are commonly excluded and covered by these supplemental plans.
*/
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T18:11:26.483253
    - Additional Notes: None
    
    */