
-- 2. Analyze how information categories have changed over time
SELECT category, mimi_src_file_date, COUNT(*) AS category_count
FROM mimi_ws_1.medlineplus.information_category
GROUP BY category, mimi_src_file_date
ORDER BY mimi_src_file_date, category_count DESC;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T18:40:20.466424
    - Additional Notes: This SQL script explores the information categories available on the MedlinePlus website, providing insights into the core focus areas and content types. The queries analyze the most common categories, how they have changed over time, and identify unique or specialized categories. The script does not contain any personally identifiable information and can be used as a foundation for further analysis and extensions.
    
    */