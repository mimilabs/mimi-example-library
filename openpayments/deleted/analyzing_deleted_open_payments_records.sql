
-- Analyzing Deleted Open Payments Records

/*
This SQL query provides insights into the deleted and removed records in the Open Payments dataset, which can be valuable for understanding the changes and quality of the data over time.

The key business value of this analysis includes:
1. Identifying patterns and trends in the types of payments that are more likely to be deleted or removed, which can help researchers and policymakers understand the underlying reasons and potential issues in the data.
2. Tracking the proportion of deleted and removed records compared to the total number of records, which can provide insights into the data quality and completeness over time.
3. Detecting any temporal patterns in the deletion or removal of records, which can help identify potential issues or biases in the data collection or reporting process.
4. Exploring associations between the change type (deleted or removed) and other variables, which can inform further investigations into the factors that lead to the removal of records from the dataset.
*/

SELECT 
  change_type,
  program_year,
  payment_type,
  COUNT(*) AS num_records
FROM mimi_ws_1.openpayments.deleted
GROUP BY change_type, program_year, payment_type
ORDER BY program_year DESC, payment_type, change_type;

/*
This query provides the following information:
1. The `change_type` column indicates whether the record was deleted or removed from the Open Payments system.
2. The `program_year` column shows the year the deleted or removed record was originally reported.
3. The `payment_type` column categorizes the type of payment (General Payment, Research Payment, or Ownership/Investment).
4. The `num_records` column shows the count of deleted or removed records for each combination of change_type, program_year, and payment_type.

By grouping and ordering the results, this query allows you to:
1. Understand the distribution of deleted and removed records across different program years and payment types.
2. Identify any patterns or trends in the types of payments that are more likely to be deleted or removed.
3. Evaluate the proportion of deleted and removed records compared to the total number of records in the Open Payments dataset for each program year.
4. Detect any temporal patterns in the deletion or removal of records.
5. Explore associations between the change type and other variables, such as payment type or program year.
*/

/*
Assumptions and Limitations:
- The deleted table does not contain the full details of the deleted or removed records, such as the names of the physicians, non-physician practitioners, or teaching hospitals involved. The data is aggregated and anonymized to protect the privacy of the individuals and organizations involved.
- The table represents a snapshot of the deleted and removed records at a specific point in time and may not include records that were deleted or removed after the data was captured.

Possible Extensions:
1. Combine the deleted table with the main Open Payments dataset to analyze the characteristics of the deleted or removed records in more detail.
2. Investigate the reasons or justifications for the deletion or removal of records, if available, to better understand the data quality and consistency.
3. Perform time series analysis to identify any seasonal or annual patterns in the deletion or removal of records.
4. Develop predictive models to identify the factors that are associated with the likelihood of a record being deleted or removed from the Open Payments dataset.
*/
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T16:52:54.741461
    - Additional Notes: None
    
    */