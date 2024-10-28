
-- Explore Alpha-1-Acid Glycoprotein Levels in the U.S. Population

-- This query explores the business value of the `mimi_ws_1.cdc.nhanes_lab_alpha1acid_glycoprotein_serum_surplus` table,
-- which contains data on Alpha-1-Acid Glycoprotein (AGP) levels in serum samples collected from NHANES participants.
-- The analysis focuses on understanding the distribution and trends of AGP levels in the U.S. population.

SELECT
  -- Extract the survey cycle from the source file name
  SUBSTRING(mimi_src_file_name, 1, INSTR(mimi_src_file_name, '_') - 1) AS survey_cycle,
  -- Calculate summary statistics for AGP levels
  MIN(ssagp) AS min_agp,
  MAX(ssagp) AS max_agp,
  AVG(ssagp) AS avg_agp,
  STDDEV(ssagp) AS std_dev_agp,
  -- Provide sample weights for extrapolation to the U.S. population
  SUM(wtssagpp) AS total_pre_pandemic_population_weight,
  SUM(wtssgp2y) AS total_2year_population_weight
FROM mimi_ws_1.cdc.nhanes_lab_alpha1acid_glycoprotein_serum_surplus
GROUP BY survey_cycle
ORDER BY survey_cycle;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T16:35:27.908258
    - Additional Notes: None
    
    */