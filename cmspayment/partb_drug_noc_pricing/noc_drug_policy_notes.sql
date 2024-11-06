-- Title: Medicare Part B NOC Drug Notes Analysis

-- Business Purpose:
-- - Extract key insights from NOC drug notes field to uncover reimbursement policies
-- - Identify drugs with special billing instructions or coverage limitations
-- - Support provider education and billing compliance initiatives
-- - Guide pricing policy decisions based on documented exceptions

-- Main Query
WITH ranked_notes AS (
  -- Get distinct drug-note combinations and rank by recency
  SELECT DISTINCT
    drug_generic_name_trade_name,
    notes,
    mimi_src_file_date,
    ROW_NUMBER() OVER (PARTITION BY drug_generic_name_trade_name 
                       ORDER BY mimi_src_file_date DESC) as note_rank
  FROM mimi_ws_1.cmspayment.partb_drug_noc_pricing
  WHERE notes IS NOT NULL
),

latest_notes AS (
  -- Keep only the most recent note for each drug
  SELECT 
    drug_generic_name_trade_name,
    notes,
    mimi_src_file_date
  FROM ranked_notes 
  WHERE note_rank = 1
)

SELECT
  drug_generic_name_trade_name,
  notes,
  mimi_src_file_date as last_updated,
  CASE 
    WHEN LOWER(notes) LIKE '%restrict%' THEN 'Coverage Restrictions'
    WHEN LOWER(notes) LIKE '%bill%' THEN 'Billing Instructions'
    WHEN LOWER(notes) LIKE '%limit%' THEN 'Usage Limitations'
    WHEN LOWER(notes) LIKE '%prior auth%' THEN 'Prior Authorization'
    ELSE 'Other Policy Notes'
  END as note_category
FROM latest_notes
ORDER BY last_updated DESC, drug_generic_name_trade_name;

-- How it works:
-- 1. First CTE gets unique drug-note combinations and ranks by date
-- 2. Second CTE filters to most recent note per drug
-- 3. Main query categorizes notes and presents final results
-- 4. Ordering ensures most recent updates appear first

-- Assumptions and Limitations:
-- - Notes field contains meaningful policy/billing information
-- - Most recent note is most relevant (historical notes dropped)
-- - Simple text matching for categories may miss nuanced policies
-- - Updates to notes field indicate actual policy changes

-- Possible Extensions:
-- 1. Add payment_limit to see correlation between notes and pricing
-- 2. Create more detailed note categories based on content analysis
-- 3. Track historical changes in notes over time
-- 4. Join with claims data to verify impact of noted policies
-- 5. Compare notes patterns across drug classes or price ranges

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:16:10.351198
    - Additional Notes: Query focuses on policy-related information in the notes field and may need adjustment of LIKE patterns based on actual note content patterns. Categories are currently limited to four main types and may need expansion based on business requirements.
    
    */