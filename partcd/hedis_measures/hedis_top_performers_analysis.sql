
/*******************************************************************************
Title: Medicare Advantage HEDIS Performance Analysis
 
Purpose: Analyze key healthcare quality metrics across Medicare Advantage contracts
to identify high-performing plans and opportunities for improvement.

Business Value:
- Identifies top performing Medicare Advantage contracts on key quality measures
- Enables comparison of performance across different healthcare quality metrics  
- Helps stakeholders understand variation in care quality
- Supports data-driven decisions for quality improvement initiatives
*******************************************************************************/

-- Get the top 10 performing contracts for key preventive care measures in the most recent year
WITH recent_year AS (
  SELECT MAX(hedis_year) as max_year 
  FROM mimi_ws_1.partcd.hedis_measures
),

key_measures AS (
  SELECT *
  FROM mimi_ws_1.partcd.hedis_measures
  WHERE hedis_year = (SELECT max_year FROM recent_year)
  -- Focus on important preventive care measures  
  AND measure_code IN ('BCS', 'COL', 'ART') -- Breast Cancer Screening, Colorectal Screening, Arthritis Management
),

ranked_contracts AS (
  SELECT 
    contract_number,
    measure_code,
    measure_name,
    rate,
    -- Calculate percentile ranking for each measure
    PERCENT_RANK() OVER (PARTITION BY measure_code ORDER BY rate) as performance_percentile
  FROM key_measures
  WHERE rate IS NOT NULL -- Exclude missing data
)

SELECT
  contract_number,
  measure_code,
  measure_name,
  ROUND(rate, 2) as rate_percentage,
  ROUND(performance_percentile * 100, 1) as percentile_rank
FROM ranked_contracts 
WHERE performance_percentile >= 0.9 -- Top 10% performers
ORDER BY measure_code, rate DESC;

/*******************************************************************************
How it works:
1. Identifies the most recent year in the dataset
2. Selects key preventive care measures for analysis
3. Calculates percentile rankings for each contract within each measure
4. Returns the top 10% performing contracts for each measure

Assumptions & Limitations:
- Focuses only on three example preventive care measures
- Assumes rate values are comparable across contracts
- Does not account for differences in patient populations
- Does not consider trend over time

Possible Extensions:
1. Add year-over-year trending analysis
2. Include geographic analysis by joining with contract location data
3. Expand to include more quality measures
4. Add statistical significance testing
5. Incorporate patient demographic factors
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:14:06.687050
    - Additional Notes: Query focuses on three specific HEDIS measures (BCS, COL, ART) and may need to be modified if different quality metrics are of interest. Performance is based on raw rates without risk adjustment, which could affect comparability across different patient populations. Consider adding contract size/denominator thresholds for more reliable comparisons.
    
    */