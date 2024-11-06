-- medicare_antibiotic_stewardship_analysis.sql

-- Business Purpose: Analyze antibiotic prescribing patterns to support antimicrobial stewardship programs by:
-- 1. Identifying providers with high-volume antibiotic prescribing
-- 2. Comparing prescribing rates across specialties and regions 
-- 3. Monitoring broad vs. narrow spectrum antibiotic usage
-- 4. Supporting efforts to reduce antibiotic resistance

WITH antibiotic_prescriptions AS (
  SELECT 
    prscrbr_npi,
    prscrbr_last_org_name,
    prscrbr_first_name,
    prscrbr_state_abrvtn,
    prscrbr_type,
    gnrc_name,
    tot_clms,
    tot_30day_fills,
    tot_benes,
    tot_drug_cst
  FROM mimi_ws_1.datacmsgov.mupdpr
  -- Focus on recent data
  WHERE mimi_src_file_date = '2022-12-31'
  -- Common antibiotics list
  AND LOWER(gnrc_name) IN (
    'amoxicillin',
    'azithromycin', 
    'cephalexin',
    'ciprofloxacin',
    'doxycycline',
    'levofloxacin',
    'nitrofurantoin',
    'trimethoprim/sulfamethoxazole'
  )
),

provider_summary AS (
  SELECT
    prscrbr_state_abrvtn AS state,
    prscrbr_type AS specialty,
    COUNT(DISTINCT prscrbr_npi) AS provider_count,
    SUM(tot_clms) AS total_prescriptions,
    SUM(tot_benes) AS total_patients,
    ROUND(SUM(tot_drug_cst),2) AS total_cost,
    ROUND(AVG(tot_30day_fills),2) AS avg_30day_fills_per_provider,
    -- Calculate prescriptions per patient ratio
    ROUND(SUM(tot_clms)::FLOAT/NULLIF(SUM(tot_benes),0),2) AS rx_per_patient
  FROM antibiotic_prescriptions
  GROUP BY 1,2
  HAVING COUNT(DISTINCT prscrbr_npi) >= 10 -- Focus on specialties with meaningful sample size
)

SELECT 
  state,
  specialty,
  provider_count,
  total_prescriptions,
  total_patients,
  total_cost,
  avg_30day_fills_per_provider,
  rx_per_patient,
  -- Calculate percent of total prescriptions by state
  ROUND(100.0 * total_prescriptions / SUM(total_prescriptions) OVER (PARTITION BY state),1) AS pct_state_prescriptions
FROM provider_summary
WHERE total_prescriptions > 1000 -- Focus on higher volume combinations
ORDER BY state, total_prescriptions DESC;

-- How this query works:
-- 1. First CTE filters for common antibiotics and recent data
-- 2. Second CTE aggregates metrics by state and provider specialty
-- 3. Final SELECT adds percentage calculations and applies volume threshold
-- 4. Results show antibiotic prescribing patterns by region and specialty

-- Assumptions & Limitations:
-- 1. Limited to pre-defined list of common antibiotics
-- 2. Does not account for appropriateness of prescribing
-- 3. Cannot determine if prescriptions were for acute vs chronic conditions
-- 4. Medicare population may not represent overall prescribing patterns

-- Possible Extensions:
-- 1. Add temporal analysis to track changes over multiple years
-- 2. Include additional antibiotics or categorize by spectrum/class
-- 3. Compare to local antibiotic resistance patterns
-- 4. Add seasonality analysis for respiratory infections
-- 5. Include provider-level details for targeted intervention programs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:30:43.332991
    - Additional Notes: Query performs state-level analysis of antibiotic prescribing but only includes 8 common antibiotics. May need to be updated with additional antibiotics based on local formularies or resistance patterns. Minimum thresholds (10 providers, 1000 prescriptions) may need adjustment for smaller regions or specialties.
    
    */