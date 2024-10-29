-- snf_occupancy_utilization_analysis.sql
-- 
-- Business Purpose:
-- Analyzes SNF bed utilization and occupancy patterns to identify capacity optimization
-- opportunities and market demand trends. This helps stakeholders make informed decisions 
-- about facility expansions, staffing levels, and market positioning.
--

WITH facility_utilization AS (
  SELECT 
    facility_name,
    state_code,
    rural_versus_urban,
    fiscal_year_end_date,
    
    -- Calculate key utilization metrics
    number_of_beds,
    total_bed_days_available,
    total_days_total,
    ROUND(total_days_total / NULLIF(total_bed_days_available, 0) * 100, 1) as occupancy_rate,
    
    -- Medicare utilization 
    total_days_title_xviii as medicare_days,
    ROUND(total_days_title_xviii / NULLIF(total_days_total, 0) * 100, 1) as medicare_mix_pct,
    
    -- Calculate average daily census
    ROUND(total_days_total / 365.0, 1) as avg_daily_census

  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_snf
  WHERE fiscal_year_end_date >= '2020-01-01'
    AND number_of_beds > 0
    AND total_bed_days_available > 0
)

SELECT
  state_code,
  rural_versus_urban,
  COUNT(DISTINCT facility_name) as facility_count,
  
  -- Occupancy metrics
  ROUND(AVG(occupancy_rate), 1) as avg_occupancy_rate,
  ROUND(AVG(medicare_mix_pct), 1) as avg_medicare_mix_pct,
  
  -- Facility size distribution
  ROUND(AVG(number_of_beds), 0) as avg_beds,
  ROUND(AVG(avg_daily_census), 0) as avg_daily_census,
  
  -- Additional detail on occupancy ranges
  SUM(CASE WHEN occupancy_rate >= 90 THEN 1 ELSE 0 END) as high_occupancy_facilities,
  SUM(CASE WHEN occupancy_rate < 80 THEN 1 ELSE 0 END) as low_occupancy_facilities

FROM facility_utilization
GROUP BY state_code, rural_versus_urban
HAVING COUNT(DISTINCT facility_name) >= 5
ORDER BY state_code, rural_versus_urban;

--
-- How this query works:
-- 1. Creates a CTE to calculate key utilization metrics at the facility level
-- 2. Aggregates data by state and rural/urban status to identify market patterns
-- 3. Focuses on recent data (2020+) and filters out facilities with invalid bed counts
-- 4. Includes occupancy distribution analysis to highlight capacity optimization opportunities
--
-- Assumptions and limitations:
-- - Assumes 365 days per year for daily census calculations
-- - Excludes markets with fewer than 5 facilities to ensure meaningful comparisons
-- - Does not account for seasonal variations in occupancy
-- - Limited to facilities reporting valid bed and utilization data
--
-- Possible extensions:
-- 1. Add year-over-year trend analysis of occupancy patterns
-- 2. Include financial metrics like revenue per occupied bed
-- 3. Segment analysis by facility size categories
-- 4. Add geographic clustering analysis for market assessment
-- 5. Incorporate quality metrics to analyze relationship with occupancy
--

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:46:56.298509
    - Additional Notes: Query provides market-level occupancy and utilization metrics for SNFs, segmented by state and rural/urban status. Best used for strategic planning and market analysis. Requires minimum of 5 facilities per market segment for meaningful results. Data from 2020 onwards only.
    
    */