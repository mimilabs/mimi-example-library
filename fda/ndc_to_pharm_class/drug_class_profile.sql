-- File: pharm_class_therapeutic_categorization.sql

-- Business Purpose:
-- Maps pharmaceutical products to their therapeutic categories using pharmacologic classifications
-- to support:
-- - Formulary management and drug list organization
-- - Clinical pathway development
-- - Therapeutic alternatives analysis
-- - Drug class standardization across healthcare systems

-- Main Query
WITH pharm_class_categories AS (
    -- Extract and standardize therapeutic categories from pharm class information
    SELECT 
        cms_ndc,
        pharm_class,
        pharm_class_type,
        CASE 
            WHEN pharm_class_type = '[EPC]' THEN 'Established'
            WHEN pharm_class_type = '[MOA]' THEN 'Mechanism'
            WHEN pharm_class_type = '[PE]' THEN 'Physiologic'
            WHEN pharm_class_type = '[CS]' THEN 'Chemical'
            ELSE 'Other'
        END AS class_category
    FROM mimi_ws_1.fda.ndc_to_pharm_class
    WHERE pharm_class IS NOT NULL
)

SELECT 
    cms_ndc,
    -- Create consolidated therapeutic profile
    MAX(CASE WHEN class_category = 'Established' THEN pharm_class END) AS established_class,
    MAX(CASE WHEN class_category = 'Mechanism' THEN pharm_class END) AS mechanism_class,
    MAX(CASE WHEN class_category = 'Physiologic' THEN pharm_class END) AS physiologic_class,
    MAX(CASE WHEN class_category = 'Chemical' THEN pharm_class END) AS chemical_class,
    -- Count number of classifications available
    COUNT(DISTINCT pharm_class) as total_classifications,
    -- Flag completeness of classification
    CASE 
        WHEN COUNT(DISTINCT class_category) = 4 THEN 'Complete'
        ELSE 'Partial'
    END AS classification_status
FROM pharm_class_categories
GROUP BY cms_ndc
HAVING total_classifications > 0
ORDER BY total_classifications DESC, cms_ndc;

-- How the Query Works:
-- 1. Creates standardized categories from pharmacologic class types
-- 2. Pivots the data to show all classification types for each NDC
-- 3. Adds metrics for classification completeness
-- 4. Filters out NDCs without any classifications

-- Assumptions and Limitations:
-- - Assumes all pharmacologic class types are correctly tagged in source data
-- - One NDC may have multiple entries for same class type
-- - Missing classifications are treated as incomplete rather than incorrect
-- - No validation against current FDA therapeutic categories

-- Possible Extensions:
-- 1. Join with NDC directory to add drug names and manufacturers
-- 2. Add therapeutic category grouping logic for formulary management
-- 3. Create completeness metrics across manufacturers
-- 4. Add comparison logic to identify similar drugs within class
-- 5. Include temporal analysis of classification changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:01:54.431678
    - Additional Notes: Query provides a consolidated view of drug classifications across all pharmacologic types (EPC, MOA, PE, CS) with completeness metrics. Best used for formulary management and therapeutic categorization purposes. Performance may be impacted with large datasets due to multiple pivots and aggregations.
    
    */