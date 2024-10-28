
/*******************************************************************************
Adverse Event Report Analysis - Core Trends and Severity
*******************************************************************************/

-- Business Purpose:  
-- Analyze trends and severity of adverse drug events to identify potential 
-- safety signals and patterns in reporting. This helps pharmacovigilance teams
-- monitor drug safety and prioritize investigation of serious adverse events.

-- Main Query
WITH yearly_stats AS (
  -- Aggregate key metrics by year
  SELECT 
    YEAR(receivedate) as report_year,
    COUNT(*) as total_reports,
    SUM(CASE WHEN serious = 1 THEN 1 ELSE 0 END) as serious_reports,
    SUM(seriousnessdeath) as death_reports,
    SUM(seriousnesshospitalization) as hospitalization_reports,
    SUM(seriousnesslifethreatening) as lifethreat_reports,
    COUNT(DISTINCT primarysourcecountry) as reporting_countries
  FROM mimi_ws_1.fda.adverse_event_base
  WHERE receivedate IS NOT NULL
  GROUP BY report_year
)

SELECT
  report_year,
  total_reports,
  serious_reports,
  -- Calculate percentages and rates
  ROUND(100.0 * serious_reports / total_reports, 1) as serious_pct,
  ROUND(100.0 * death_reports / serious_reports, 1) as death_pct,
  ROUND(100.0 * hospitalization_reports / serious_reports, 1) as hosp_pct,
  ROUND(100.0 * lifethreat_reports / serious_reports, 1) as lifethreat_pct,
  reporting_countries
FROM yearly_stats
WHERE report_year >= 2018  -- Focus on recent years
ORDER BY report_year DESC;

/*******************************************************************************
How this query works:
- Creates yearly aggregates of adverse event reports
- Calculates total reports and breaks down by severity types
- Computes percentages of serious events and specific outcomes
- Shows geographic spread through distinct reporting countries
- Filters to recent years for more relevant trending

Assumptions and Limitations:
1. Relies on accurate severity flagging in source data
2. Only counts reports with valid receive dates
3. Does not account for reporting delays or updates
4. Geographic spread may be affected by reporting requirements

Possible Extensions:
1. Add monthly/quarterly trending
2. Break down by patient demographics (age groups, gender)
3. Include reporter qualification analysis
4. Add comparison across different report types
5. Incorporate time lag analysis between event and reporting dates
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:08:09.388201
    - Additional Notes: Query focuses on year-over-year trends in adverse event reporting severity, with particular emphasis on serious outcomes (deaths, hospitalizations, life-threatening events). Best used for annual safety signal detection and reporting pattern analysis. Note that percentages are calculated against serious cases rather than total cases to highlight the distribution of severe outcomes.
    
    */