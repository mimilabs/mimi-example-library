-- drug_adherence_patterns.sql

-- Business Purpose: 
-- Analyze prescription medication adherence patterns by looking at days supplied and refill timing
-- This helps identify gaps in medication compliance and opportunities for improving patient outcomes
-- Key stakeholders: Population Health teams, Care Management, Quality Programs

-- Main Query
WITH patient_med_timeline AS (
  -- Get medication history by patient
  SELECT 
    dupersid,
    rxdrgnam,
    rxbegmm,
    rxbegyrx,
    rxdaysup,
    -- Calculate next fill date for same medication
    LEAD(rxbegyrx * 100 + rxbegmm) OVER (
      PARTITION BY dupersid, rxdrgnam 
      ORDER BY rxbegyrx * 100 + rxbegmm
    ) as next_fill_date,
    -- Get days until next fill
    LEAD(rxdaysup) OVER (
      PARTITION BY dupersid, rxdrgnam 
      ORDER BY rxbegyrx * 100 + rxbegmm
    ) as next_days_supply
  FROM mimi_ws_1.ahrq.meps_event_prescribedmeds
  WHERE rxdaysup > 0 
  AND rxbegmm IS NOT NULL
  AND rxbegyrx IS NOT NULL
)

SELECT
  rxdrgnam,
  COUNT(DISTINCT dupersid) as total_patients,
  ROUND(AVG(rxdaysup), 1) as avg_days_supply,
  -- Calculate average gap between fills
  ROUND(AVG(
    CASE WHEN next_fill_date IS NOT NULL 
    THEN (next_fill_date - (rxbegyrx * 100 + rxbegmm)) - rxdaysup
    END
  ), 1) as avg_gap_days,
  -- Flag potential non-adherence
  ROUND(SUM(CASE 
    WHEN next_fill_date IS NOT NULL 
    AND ((next_fill_date - (rxbegyrx * 100 + rxbegmm)) - rxdaysup) > 7
    THEN 1 ELSE 0 
  END) * 100.0 / COUNT(*), 1) as pct_delayed_refills
FROM patient_med_timeline
GROUP BY rxdrgnam
HAVING COUNT(DISTINCT dupersid) >= 100
ORDER BY total_patients DESC
LIMIT 20;

-- How it works:
-- 1. Creates patient medication timeline with fill dates and days supply
-- 2. Uses window functions to look at sequential fills of same medication
-- 3. Calculates gaps between expected and actual refill dates
-- 4. Aggregates to medication level to show adherence patterns

-- Assumptions & Limitations:
-- - Assumes prescription dates and days supply are accurate
-- - May underestimate adherence if patients get 90-day supplies
-- - Doesn't account for intentional discontinuation
-- - Limited to medications with sufficient sample size

-- Possible Extensions:
-- 1. Add therapeutic class analysis to group similar medications
-- 2. Include demographics to identify disparities
-- 3. Calculate proportion of days covered (PDC)
-- 4. Focus on specific chronic conditions
-- 5. Add cost impact analysis of non-adherence

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:49:02.452084
    - Additional Notes: Query targets medication compliance by calculating refill gaps. Results best used with medications intended for continuous use. May need adjustment for seasonal medications or those taken as-needed. Consider adding filters for specific therapeutic classes if focusing on particular conditions.
    
    */