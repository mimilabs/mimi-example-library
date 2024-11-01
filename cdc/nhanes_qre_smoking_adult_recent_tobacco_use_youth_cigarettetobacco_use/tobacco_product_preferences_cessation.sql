-- Title: NHANES Tobacco Product Preferences and Cessation Attempts Analysis

/*
Business Purpose:
- Analyze tobacco product preferences and brand choices among survey respondents
- Evaluate cessation attempt patterns and nicotine replacement therapy usage
- Support tobacco control programs and smoking cessation initiatives
- Guide targeted interventions for specific tobacco product users
*/

WITH tobacco_preferences AS (
    -- Identify respondents who used tobacco in past 5 days
    SELECT 
        seqn,
        smq680 as used_tobacco_past_5days,
        smq670 as quit_attempt_past_year,
        -- Aggregate different tobacco products used
        CASE WHEN smq690a = 1 THEN 1 ELSE 0 END as used_cigarettes,
        CASE WHEN smq690b = 1 THEN 1 ELSE 0 END as used_pipes,
        CASE WHEN smq690c = 1 THEN 1 ELSE 0 END as used_cigars,
        CASE WHEN smq690d = 1 THEN 1 ELSE 0 END as used_chewing_tobacco,
        CASE WHEN smq690e = 1 THEN 1 ELSE 0 END as used_snuff,
        CASE WHEN smq690f = 1 THEN 1 ELSE 0 END as used_nicotine_replacement,
        -- Capture brand preferences for cigarette smokers
        CASE 
            WHEN smq660 = 2 THEN 'Benson & Hedges'
            WHEN smq660 = 3 THEN 'Camel'
            WHEN smq660 = 13 THEN 'Marlboro'
            WHEN smq660 = 16 THEN 'Newport'
            ELSE 'Other'
        END as preferred_brand
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_adult_recent_tobacco_use_youth_cigarettetobacco_use
    WHERE smq680 = 1  -- Only include those who used tobacco
)

SELECT 
    -- Calculate product usage statistics
    COUNT(DISTINCT seqn) as total_tobacco_users,
    ROUND(AVG(used_cigarettes) * 100, 1) as pct_cigarette_users,
    ROUND(AVG(used_pipes) * 100, 1) as pct_pipe_users,
    ROUND(AVG(used_cigars) * 100, 1) as pct_cigar_users,
    ROUND(AVG(used_chewing_tobacco) * 100, 1) as pct_chewing_tobacco_users,
    ROUND(AVG(used_nicotine_replacement) * 100, 1) as pct_using_cessation_products,
    -- Analyze brand preferences
    preferred_brand,
    COUNT(*) as brand_users,
    -- Calculate quit attempt rate
    ROUND(AVG(CASE WHEN quit_attempt_past_year = 1 THEN 1 ELSE 0 END) * 100, 1) as pct_attempted_quitting
FROM tobacco_preferences
GROUP BY preferred_brand
ORDER BY brand_users DESC;

/*
How the Query Works:
1. Creates a CTE to transform raw survey responses into analyzable metrics
2. Consolidates multiple tobacco product types into binary indicators
3. Maps cigarette brand codes to readable names
4. Calculates usage percentages and quit attempt rates by brand preference

Assumptions and Limitations:
- Assumes valid responses (non-null) for key fields
- Limited to most recent survey responses
- Brand preferences only captured for cigarette users
- Does not account for survey weights or sampling methodology

Possible Extensions:
1. Add demographic breakdowns (age, gender, socioeconomic status)
2. Include temporal trends by mimi_src_file_date
3. Analyze menthol vs non-menthol preferences
4. Compare successful vs unsuccessful quit attempts
5. Incorporate frequency of use patterns
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:19:35.138261
    - Additional Notes: Query focuses on tobacco product mix and cessation patterns across different brand users. Consider adding survey weights (if available) for more accurate population-level estimates. Brand preference analysis is limited to cigarette users only.
    
    */