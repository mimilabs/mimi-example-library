
/*************************************************************************
Title: Rural Health Clinic Ownership Analysis
 
Business Purpose:
- Analyze ownership patterns of Rural Health Clinics (RHCs) to understand:
  * Distribution between individual vs organizational ownership
  * Ownership percentages and concentration
  * Types of organizational owners
- Support healthcare policy and planning by providing insights into RHC ownership structures
**************************************************************************/

WITH latest_data AS (
  -- Get most recent snapshot based on source file date
  SELECT *
  FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
  WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
  )
)

SELECT 
  -- Overall ownership type distribution
  COUNT(DISTINCT enrollment_id) as total_clinics,
  
  -- Individual vs Org breakdown
  SUM(CASE WHEN type_owner = 'I' THEN 1 ELSE 0 END) as individual_owners,
  SUM(CASE WHEN type_owner = 'O' THEN 1 ELSE 0 END) as org_owners,
  
  -- Ownership concentration 
  AVG(CAST(percentage_ownership AS DECIMAL(5,2))) as avg_ownership_pct,
  
  -- Organization type breakdown
  SUM(CASE WHEN corporation_owner = 'Y' THEN 1 ELSE 0 END) as corporate_owners,
  SUM(CASE WHEN llc_owner = 'Y' THEN 1 ELSE 0 END) as llc_owners,
  SUM(CASE WHEN non_profit_owner = 'Y' THEN 1 ELSE 0 END) as nonprofit_owners,
  SUM(CASE WHEN for_profit_owner = 'Y' THEN 1 ELSE 0 END) as forprofit_owners,
  
  -- Investment-related owners
  SUM(CASE WHEN investment_firm_owner = 'Y' 
           OR financial_institution_owner = 'Y' 
           OR holding_company_owner = 'Y' THEN 1 ELSE 0 END) as investment_related_owners
FROM latest_data

/*
How it works:
1. CTE gets most recent data snapshot
2. Main query calculates key ownership metrics:
   - Total clinic count
   - Individual vs organizational split
   - Average ownership percentage 
   - Counts by organization type

Assumptions/Limitations:
- Uses most recent snapshot only - no historical trending
- Ownership percentages may not sum to 100% per clinic
- Some clinics may have multiple owners
- Organization type flags are not mutually exclusive

Possible Extensions:
1. Add geographic analysis by owner state
2. Trend analysis across multiple snapshots
3. Detailed ownership role analysis
4. Ownership network analysis between clinics
5. Correlation with clinic size/performance metrics
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:25:41.650584
    - Additional Notes: The query provides a single-row summary output focusing on the high-level ownership distribution. Users should note that ownership percentages and type categorizations may overlap, as clinics can have multiple owners with different characteristics. The analysis is limited to the most recent snapshot and does not reflect historical changes in ownership structure.
    
    */