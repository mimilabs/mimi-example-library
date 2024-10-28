
-- Analyzing Drug Patent Exclusivity and Competition

/*
This query explores the business value of the `mimi_ws_1.fda.orangebook_patent` table,
which provides insights into the patent landscape for approved drug products in the
FDA's Orange Book. By analyzing this data, we can gain a better understanding of
drug patent exclusivity, the potential for generic competition, and the lifecycle
of pharmaceutical products.
*/

SELECT 
  appl_type,
  COUNT(DISTINCT appl_no) AS num_applications,
  COUNT(DISTINCT patent_no) AS num_patents,
  MIN(patent_expire_date_text) AS earliest_patent_expiry,
  MAX(patent_expire_date_text) AS latest_patent_expiry
FROM mimi_ws_1.fda.orangebook_patent
GROUP BY appl_type
ORDER BY num_patents DESC;

/*
This query provides several key insights:

1. It groups the data by application type (e.g., NDA, ANDA) and counts the number
   of distinct applications and patents for each type. This can help identify
   differences in patent strategies between brand-name and generic drug products.

2. It finds the earliest and latest patent expiration dates for each application
   type. This information can be used to estimate the potential market exclusivity
   period for different types of drug products.

3. The results can be used to identify therapeutic areas or drug categories with
   the most extensive patent protection, which may face delayed generic
   competition.

Assumptions and Limitations:
- The patent expiration dates are based on the information submitted by the
  drug manufacturers and may be subject to change due to legal challenges
  or other factors.
- The table does not include information on unapproved or investigational drugs,
  so the analysis is limited to approved drug products only.

Possible Extensions:
- Analyze the relationship between the number of patents and the duration of
  market exclusivity for different drug products.
- Investigate the types of patents (e.g., drug substance, drug product, method
  of use) and their impact on competition.
- Explore the distribution of patent expiration dates across different
  therapeutic areas or drug categories.
- Identify potential opportunities for generic competition based on upcoming
  patent expiries.
*/
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T19:20:10.941893
    - Additional Notes: None
    
    */