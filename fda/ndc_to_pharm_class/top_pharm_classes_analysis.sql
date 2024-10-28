
/*******************************************************************************
Title: Common Pharmacologic Classes Analysis
 
Business Purpose:
- Analyze distribution of pharmacologic classes across drugs to understand 
  treatment categories in the FDA database
- Identify predominant mechanisms of action and physiologic effects
- Support drug classification and potential interaction analysis
*******************************************************************************/

-- Get the top 10 most common pharmacologic classes and their types
-- along with count of associated drug products
SELECT 
    pharm_class,
    pharm_class_type,
    COUNT(DISTINCT product_ndc) as drug_count
FROM mimi_ws_1.fda.ndc_to_pharm_class
WHERE pharm_class IS NOT NULL
GROUP BY pharm_class, pharm_class_type

-- Focus on the classes with significant representation
HAVING COUNT(DISTINCT product_ndc) >= 10

-- Order by frequency to see most common classes
ORDER BY drug_count DESC
LIMIT 10;

/*******************************************************************************
How this query works:
1. Groups drugs by their pharmacologic class and type
2. Counts distinct products (using product_ndc) for each class
3. Filters to classes with 10+ products for significance
4. Orders by frequency to surface most common classes

Assumptions & Limitations:
- Uses product_ndc for distinct drug counting (vs package_ndc or cms_ndc)
- Assumes NULL pharmacologic classes should be excluded
- Limited to top 10 results for initial analysis
- Does not account for time dimension or changes over time

Possible Extensions:
1. Add time trend analysis using mimi_src_file_date
2. Break down by specific types (MOA, PE, CS, EPC)
3. Cross-reference with ndc_directory for additional drug properties
4. Compare class distributions across different manufacturers
5. Analyze co-occurring pharmacologic classes for same drugs
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:59:51.018530
    - Additional Notes: Query focuses on high-level pharmacologic class distribution patterns. Filter threshold of 10 products may need adjustment based on data volume. Consider adding manufacturer details from ndc_directory table for more comprehensive analysis.
    
    */