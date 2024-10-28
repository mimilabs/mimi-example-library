
-- Analyzing Part D Drug Pricing Trends

/*
Business Purpose: The `mimi_ws_1.prescriptiondrugplan.pricing` table provides valuable insights into the average monthly costs for formulary Part D drugs at the plan level. This information can help researchers and policymakers understand pricing trends, variations, and patterns across different Medicare Prescription Drug Plans and Medicare Advantage Prescription Drug Plans. By analyzing this data, we can gain insights that can inform decision-making, policy development, and ultimately improve the affordability and accessibility of prescription drugs for Medicare beneficiaries.
*/

-- Analyze the average monthly costs for formulary Part D drugs by plan
SELECT 
  contract_id,
  plan_id,
  segment_id,
  ndc,
  days_supply,
  AVG(unit_cost) AS avg_unit_cost
FROM mimi_ws_1.prescriptiondrugplan.pricing
GROUP BY contract_id, plan_id, segment_id, ndc, days_supply
ORDER BY avg_unit_cost DESC;

/*
This query aggregates the pricing data by contract ID, plan ID, segment ID, NDC, and days' supply. It calculates the average unit cost for each unique combination of these variables, allowing us to explore how the average monthly costs vary across different plans and drug products.

By ordering the results by the average unit cost in descending order, we can quickly identify the drugs with the highest average monthly costs, which may be of particular interest for further analysis.

The key business insights that can be derived from this query include:

1. Identifying plans with the highest and lowest average monthly costs for specific drugs or drug categories.
2. Analyzing how the average monthly costs differ between 30-day, 60-day, and 90-day supplies of the same drug, which can inform discussions around medication adherence and cost-effective dispensing practices.
3. Detecting significant pricing differences for the same drug across different plans, which could be a starting point for investigating potential factors contributing to these variations (e.g., negotiated rebates, geographic differences, plan design).
4. Tracking trends in average monthly costs over time by using the `mimi_src_file_date` column as a proxy for the data publication date.

Assumptions and Limitations:
- The data only provides average monthly costs at the plan level, not individual patient-level costs or specific drug prices.
- The table is a snapshot of pricing information for a specific quarter, and it may not capture any changes or fluctuations in prices that occur within that quarter or over a longer period.
- The data is anonymized, and the actual provider names and addresses are not included, which may limit the ability to link the pricing information to specific healthcare providers or pharmacies.

Possible Extensions:
1. Combine the pricing data with the `plan_information` table to analyze how plan characteristics (e.g., plan type, geographic region) may influence the average monthly costs.
2. Incorporate the `basic_drugs_formulary` table to explore how the pricing of drugs on different cost-sharing tiers (e.g., generic, preferred brand, non-preferred brand) varies within and across plans.
3. Investigate the relationship between the average monthly costs and the geographic location of the plans using the `geographic_locator` table.
4. Perform longitudinal analysis to identify pricing trends and changes over multiple quarters or years.
*/
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T18:23:20.997503
    - Additional Notes: This SQL script provides a foundational analysis of the average monthly costs for formulary Part D drugs across different Medicare Prescription Drug Plans and Medicare Advantage Prescription Drug Plans. It allows researchers and policymakers to explore pricing trends, variations, and patterns that can inform decision-making and policy development to improve the affordability and accessibility of prescription drugs for Medicare beneficiaries.
    
    */