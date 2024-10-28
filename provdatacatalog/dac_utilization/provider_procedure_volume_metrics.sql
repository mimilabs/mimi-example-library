
/*************************************************************************
Title: Clinician Procedure Volume Analysis - Core Metrics
 
Business Purpose:
This query analyzes procedure volumes across clinicians to:
1. Identify high-volume providers
2. Compare procedure volumes across specialties
3. Support clinical resource planning and quality assessment

The results help healthcare organizations:
- Understand provider utilization patterns
- Identify capacity constraints
- Support credentialing and quality reviews
*************************************************************************/

-- Get the most recent procedure volume data and rank providers
WITH recent_data AS (
  SELECT *
  FROM mimi_ws_1.provdatacatalog.dac_utilization
  WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.provdatacatalog.dac_utilization
  )
),

-- Calculate summary metrics per provider
provider_summary AS (
  SELECT 
    npi,
    provider_last_name,
    provider_first_name,
    COUNT(DISTINCT procedure_category) as num_procedure_types,
    SUM(count) as total_procedures,
    AVG(percentile) as avg_percentile
  FROM recent_data
  GROUP BY 1,2,3
)

-- Generate final analysis 
SELECT
  p.provider_last_name,
  p.provider_first_name,
  p.num_procedure_types,
  p.total_procedures,
  ROUND(p.avg_percentile,2) as avg_procedure_percentile,
  
  -- Get top procedure category by volume
  FIRST_VALUE(r.procedure_category) OVER (
    PARTITION BY p.npi 
    ORDER BY r.count DESC
  ) as top_procedure_category,
  
  -- Get count for top procedure
  FIRST_VALUE(r.count) OVER (
    PARTITION BY p.npi 
    ORDER BY r.count DESC
  ) as top_procedure_count

FROM provider_summary p
JOIN recent_data r ON p.npi = r.npi

-- Focus on providers with significant volume
WHERE p.total_procedures >= 100

-- Order by total procedure volume
ORDER BY p.total_procedures DESC
LIMIT 100;

/*************************************************************************
How this query works:
1. Gets most recent data snapshot
2. Calculates provider-level summary metrics
3. Joins back to procedure details to get top categories
4. Filters and ranks providers by volume

Assumptions & Limitations:
- Uses most recent data snapshot only
- Focuses on high-volume providers (>=100 procedures)
- Limited to top 100 providers by volume
- Doesn't account for provider specialties or geography

Possible Extensions:
1. Add geographic analysis by joining provider location data
2. Compare volumes across specialties/provider types
3. Analyze trends over time using historical snapshots
4. Add statistical analysis of volume distributions
5. Create provider peer group comparisons
*************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:00:12.925424
    - Additional Notes: The query focuses on high-volume providers (>=100 procedures) and uses the most recent data snapshot only. It provides key metrics including total procedure counts, procedure type diversity, and percentile rankings. Note that the results are limited to top 100 providers and do not include specialty-specific analysis. Consider adjusting the volume threshold (100) and result limit (100) based on specific analysis needs.
    
    */