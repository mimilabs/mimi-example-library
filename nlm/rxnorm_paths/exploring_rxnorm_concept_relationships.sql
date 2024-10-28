
-- Exploring RxNorm Concept Relationships with the `rxnorm_paths` Table

/*
The `mimi_ws_1.nlm.rxnorm_paths` table provides a hierarchical representation of RxNorm concepts, allowing users to understand the relationships between different drug entities. This information can be valuable for a variety of use cases, such as:

1. Identifying alternative or similar medications based on the relationships between drug concepts.
2. Studying the coverage and comprehensiveness of the RxNorm vocabulary in representing various drug entities.
3. Developing tools to detect potential drug-drug interactions or contraindications based on the proximity of drug concepts in the RxNorm structure.
4. Enabling researchers to explore the most common types of relationships between drug concepts in the RxNorm terminology.

This query demonstrates the core business value of the `rxnorm_paths` table by providing insights into the structure and relationships within the RxNorm vocabulary.
*/

SELECT
  -- Extract the concept type abbreviations from the 'path' column
  REGEXP_EXTRACT(path_element, '([A-Z]+)$') AS concept_type,
  -- Count the number of occurrences for each concept type
  COUNT(*) AS concept_count
FROM
  (
    SELECT
      explode(path) as path_element
    FROM
      mimi_ws_1.nlm.rxnorm_paths
  )
GROUP BY
  concept_type
-- Order the results by the concept count in descending order
ORDER BY
  concept_count DESC;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T18:46:15.820835
    - Additional Notes: This query provides insights into the hierarchical structure and most common concept types within the RxNorm vocabulary, which can be useful for identifying related medications, studying vocabulary coverage, and detecting potential drug interactions. However, it is important to note that the data represents a snapshot in time and may not reflect the most recent updates to the RxNorm terminology.
    
    */