
-- Analyze NDC to RxCUI Mapping

/*
This query demonstrates the core business value of the `mimi_ws_1.fda.ndc_to_rxcui` table.

The main objectives are:
1. Identify the most common RxCUI codes associated with a given NDC.
2. Determine the number of unique RxCUI codes mapped to each NDC.
3. Find the NDCs with the highest number of associated RxCUI codes.

By understanding the mapping between NDCs and RxCUIs, researchers can:
- Link drug information from the FDA's NDC Directory with other datasets, such as prescription drug plan data.
- Gain insights into drug usage, pricing, and coverage across various health plans.
*/

SELECT
  cms_ndc,
  COUNT(DISTINCT rxcui) AS num_unique_rxcui,
  COLLECT_LIST(rxcui) AS rxcui_list,
  MAX(mimi_src_file_date) AS max_src_file_date
FROM mimi_ws_1.fda.ndc_to_rxcui
GROUP BY cms_ndc
ORDER BY num_unique_rxcui DESC
LIMIT 10;

/*
This query performs the following steps:

1. Selects the `cms_ndc`, `rxcui`, and metadata columns (`mimi_src_file_date`) from the `ndc_to_rxcui` table.
2. Groups the data by the `cms_ndc` column to calculate the number of unique `rxcui` codes per NDC.
3. Uses the `COUNT(DISTINCT rxcui)` function to determine the number of unique `rxcui` codes per NDC.
4. Leverages the `COLLECT_LIST(rxcui)` function to create a list of all `rxcui` codes associated with each NDC.
5. Finds the maximum `mimi_src_file_date` to identify the most recent data source.
6. Orders the results by the number of unique `rxcui` codes in descending order.
7. Limits the output to the top 10 NDCs with the most associated `rxcui` codes.

This query provides valuable insights into the mapping between NDCs and RxCUIs, which can be used to:
- Understand the breadth of drug coverage for a given NDC.
- Identify drugs with the most diverse therapeutic uses (as indicated by the number of associated RxCUIs).
- Track changes in the NDC to RxCUI mapping over time by monitoring the `mimi_src_file_date`.

Assumptions:
- The data in the `ndc_to_rxcui` table is up-to-date and accurately reflects the current NDC to RxCUI mappings.
- The `cms_ndc` column is the primary key for linking this table with other datasets, such as the `ndc_directory`.

Possible extensions:
- Join the `ndc_to_rxcui` table with the `ndc_directory` table to enrich the output with additional drug information (e.g., drug name, active ingredients).
- Analyze the distribution of RxCUI codes per NDC to identify outliers or unusual patterns.
- Investigate the relationships between NDCs, RxCUIs, and other datasets (e.g., prescription drug plan data) to uncover insights into drug usage, pricing, and coverage.
*/
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T17:27:20.588261
    - Additional Notes: None
    
    */