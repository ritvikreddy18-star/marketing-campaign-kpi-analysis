-- ============================================================
-- Digital Marketing Campaign Performance & KPI Analysis
-- Tool: PostgreSQL
-- Author: Ritvik Reddy Jillella
-- Dataset: Marketing Campaign Performance — 200,000 records
-- Period: January 2021 – December 2021
-- ============================================================


-- ============================================================
-- SECTION 0: TABLE SETUP
-- ============================================================

DROP TABLE IF EXISTS marketing_campaigns;

CREATE TABLE marketing_campaigns (
    campaign_id         INTEGER,
    company             VARCHAR(200),
    campaign_type       VARCHAR(50),
    target_audience     VARCHAR(50),
    duration            VARCHAR(20),
    channel_used        VARCHAR(50),
    conversion_rate     NUMERIC(6,4),
    acquisition_cost    VARCHAR(20),
    roi                 NUMERIC(6,4),
    location            VARCHAR(50),
    language            VARCHAR(50),
    clicks              INTEGER,
    impressions         INTEGER,
    engagement_score    INTEGER,
    customer_segment    VARCHAR(100),
    date                DATE
);

-- Import: pgAdmin → right-click table → Import/Export Data
-- File: marketing_campaign_dataset.csv | Delimiter: , | Header: ON


-- ============================================================
-- SECTION 1: DATA CLEANING & PREPARATION
-- ============================================================

-- 1.1 Add cleaned numeric acquisition cost column
ALTER TABLE marketing_campaigns
    ADD COLUMN IF NOT EXISTS cost_clean NUMERIC(12,2);

UPDATE marketing_campaigns
SET cost_clean = REPLACE(REPLACE(acquisition_cost, '$', ''), ',', '')::NUMERIC(12,2);

-- 1.2 Add calculated KPI columns
ALTER TABLE marketing_campaigns
    ADD COLUMN IF NOT EXISTS ctr         NUMERIC(8,6),
    ADD COLUMN IF NOT EXISTS cpm         NUMERIC(10,4),
    ADD COLUMN IF NOT EXISTS cpc         NUMERIC(10,4),
    ADD COLUMN IF NOT EXISTS month_num   INTEGER,
    ADD COLUMN IF NOT EXISTS quarter     VARCHAR(5);

UPDATE marketing_campaigns
SET
    ctr       = ROUND(clicks::NUMERIC / NULLIF(impressions, 0), 6),
    cpm       = ROUND(cost_clean / NULLIF(impressions, 0) * 1000, 4),
    cpc       = ROUND(cost_clean / NULLIF(clicks, 0), 4),
    month_num = EXTRACT(MONTH FROM date),
    quarter   = 'Q' || EXTRACT(QUARTER FROM date)::TEXT;

-- 1.3 Verify record count and data integrity
SELECT
    COUNT(*)                            AS total_records,
    COUNT(DISTINCT company)             AS unique_companies,
    COUNT(DISTINCT campaign_type)       AS campaign_types,
    COUNT(DISTINCT channel_used)        AS channels,
    COUNT(DISTINCT location)            AS locations,
    COUNT(DISTINCT customer_segment)    AS customer_segments,
    MIN(date)                           AS start_date,
    MAX(date)                           AS end_date
FROM marketing_campaigns;


-- ============================================================
-- SECTION 2: OVERALL PERFORMANCE KPIs
-- ============================================================

-- 2.1 Executive KPI summary
SELECT
    COUNT(*)                                        AS total_campaigns,
    SUM(clicks)                                     AS total_clicks,
    SUM(impressions)                                AS total_impressions,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(roi), 2)                              AS avg_roi,
    ROUND(AVG(cost_clean), 0)                       AS avg_acquisition_cost,
    ROUND(SUM(cost_clean) / 1000000, 2)             AS total_spend_millions,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement_score,
    ROUND(AVG(cpc), 2)                              AS avg_cpc,
    ROUND(AVG(cpm), 2)                              AS avg_cpm
FROM marketing_campaigns;

-- 2.2 Performance benchmark — above vs below average ROI
SELECT
    CASE
        WHEN roi >= 5.0 THEN 'Above Average ROI'
        ELSE 'Below Average ROI'
    END AS performance_tier,
    COUNT(*)                                        AS campaign_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_total,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_pct,
    ROUND(AVG(cost_clean), 0)                       AS avg_cost
FROM marketing_campaigns
GROUP BY performance_tier
ORDER BY avg_roi DESC;


-- ============================================================
-- SECTION 3: CHANNEL PERFORMANCE ANALYSIS
-- ============================================================

-- 3.1 Full channel KPI breakdown
SELECT
    channel_used,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(cost_clean), 0)                       AS avg_acquisition_cost,
    ROUND(AVG(cpc), 2)                              AS avg_cpc,
    ROUND(AVG(cpm), 2)                              AS avg_cpm,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement_score,
    SUM(clicks)                                     AS total_clicks,
    SUM(impressions)                                AS total_impressions
FROM marketing_campaigns
GROUP BY channel_used
ORDER BY avg_roi DESC;

-- 3.2 Channel efficiency ranking — cost per conversion
SELECT
    channel_used,
    ROUND(AVG(cost_clean), 0)                       AS avg_acquisition_cost,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(cost_clean) / NULLIF(AVG(conversion_rate) * AVG(clicks), 0), 2) AS est_cost_per_conversion,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    RANK() OVER (ORDER BY AVG(roi) DESC)            AS roi_rank,
    RANK() OVER (ORDER BY AVG(cost_clean) ASC)      AS cost_efficiency_rank
FROM marketing_campaigns
GROUP BY channel_used
ORDER BY roi_rank;

-- 3.3 Channel vs campaign type cross-analysis
SELECT
    channel_used,
    campaign_type,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct
FROM marketing_campaigns
GROUP BY channel_used, campaign_type
ORDER BY avg_roi DESC;


-- ============================================================
-- SECTION 4: CAMPAIGN TYPE PERFORMANCE
-- ============================================================

-- 4.1 Campaign type KPI comparison
SELECT
    campaign_type,
    COUNT(*)                                        AS total_campaigns,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(cost_clean), 0)                       AS avg_acquisition_cost,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement_score,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    ROUND(AVG(cpc), 2)                              AS avg_cpc,
    SUM(clicks)                                     AS total_clicks
FROM marketing_campaigns
GROUP BY campaign_type
ORDER BY avg_roi DESC;

-- 4.2 Campaign duration impact on performance
SELECT
    duration,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(cost_clean), 0)                       AS avg_cost,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement
FROM marketing_campaigns
GROUP BY duration
ORDER BY avg_roi DESC;


-- ============================================================
-- SECTION 5: AUDIENCE SEGMENTATION ANALYSIS
-- ============================================================

-- 5.1 Performance by customer segment
SELECT
    customer_segment,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(cost_clean), 0)                       AS avg_acquisition_cost,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement_score,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    RANK() OVER (ORDER BY AVG(roi) DESC)            AS roi_rank
FROM marketing_campaigns
GROUP BY customer_segment
ORDER BY avg_roi DESC;

-- 5.2 Performance by target audience (age/gender)
SELECT
    target_audience,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement,
    ROUND(AVG(cost_clean), 0)                       AS avg_cost
FROM marketing_campaigns
GROUP BY target_audience
ORDER BY avg_roi DESC;

-- 5.3 Best channel per customer segment
SELECT
    customer_segment,
    channel_used,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    COUNT(*)                                        AS campaigns
FROM marketing_campaigns
GROUP BY customer_segment, channel_used
ORDER BY customer_segment, avg_roi DESC;


-- ============================================================
-- SECTION 6: GEOGRAPHIC PERFORMANCE ANALYSIS
-- ============================================================

-- 6.1 Performance by location
SELECT
    location,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(cost_clean), 0)                       AS avg_acquisition_cost,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement,
    SUM(clicks)                                     AS total_clicks,
    RANK() OVER (ORDER BY AVG(roi) DESC)            AS roi_rank
FROM marketing_campaigns
GROUP BY location
ORDER BY avg_roi DESC;

-- 6.2 Location vs channel combination performance
SELECT
    location,
    channel_used,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_pct
FROM marketing_campaigns
GROUP BY location, channel_used
ORDER BY location, avg_roi DESC;


-- ============================================================
-- SECTION 7: MONTHLY & QUARTERLY TREND ANALYSIS
-- ============================================================

-- 7.1 Monthly KPI trend
SELECT
    month_num,
    TO_CHAR(date, 'Month')                          AS month_name,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    SUM(clicks)                                     AS total_clicks,
    ROUND(AVG(cost_clean), 0)                       AS avg_cost,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement
FROM marketing_campaigns
GROUP BY month_num, TO_CHAR(date, 'Month')
ORDER BY month_num;

-- 7.2 Month-over-month ROI growth
WITH monthly_roi AS (
    SELECT
        month_num,
        ROUND(AVG(roi), 4) AS avg_roi
    FROM marketing_campaigns
    GROUP BY month_num
)
SELECT
    month_num,
    avg_roi,
    LAG(avg_roi) OVER (ORDER BY month_num)          AS prev_month_roi,
    ROUND((avg_roi - LAG(avg_roi) OVER (ORDER BY month_num)) * 100.0 /
          NULLIF(LAG(avg_roi) OVER (ORDER BY month_num), 0), 2) AS mom_roi_change_pct
FROM monthly_roi
ORDER BY month_num;

-- 7.3 Quarterly performance summary
SELECT
    quarter,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    SUM(clicks)                                     AS total_clicks,
    ROUND(AVG(cost_clean), 0)                       AS avg_cost
FROM marketing_campaigns
GROUP BY quarter
ORDER BY quarter;

-- 7.4 Best performing month per channel
SELECT
    channel_used,
    month_num,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_pct
FROM marketing_campaigns
GROUP BY channel_used, month_num
QUALIFY ROW_NUMBER() OVER (PARTITION BY channel_used ORDER BY AVG(roi) DESC) = 1
ORDER BY avg_roi DESC;
-- Note: If QUALIFY unsupported, use subquery:
/*
SELECT channel_used, month_num, avg_roi, avg_conversion_pct
FROM (
    SELECT channel_used, month_num,
           ROUND(AVG(roi), 3) AS avg_roi,
           ROUND(AVG(conversion_rate)*100, 2) AS avg_conversion_pct,
           ROW_NUMBER() OVER (PARTITION BY channel_used ORDER BY AVG(roi) DESC) AS rn
    FROM marketing_campaigns GROUP BY channel_used, month_num
) t WHERE rn = 1 ORDER BY avg_roi DESC;
*/


-- ============================================================
-- SECTION 8: KPI PERFORMANCE SCORING & RANKING
-- ============================================================

-- 8.1 Company performance ranking (top 20)
SELECT
    company,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement,
    ROUND(AVG(cost_clean), 0)                       AS avg_cost,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct
FROM marketing_campaigns
GROUP BY company
ORDER BY avg_roi DESC
LIMIT 20;

-- 8.2 High-performance campaign identification
-- Campaigns in top quartile for both ROI and conversion rate
SELECT
    campaign_id,
    company,
    campaign_type,
    channel_used,
    location,
    customer_segment,
    roi,
    ROUND(conversion_rate * 100, 2)                 AS conversion_rate_pct,
    ROUND(ctr * 100, 2)                             AS ctr_pct,
    cost_clean,
    engagement_score
FROM marketing_campaigns
WHERE roi >= PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY roi) OVER ()
  AND conversion_rate >= PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY conversion_rate) OVER ()
ORDER BY roi DESC
LIMIT 25;

-- 8.3 Underperforming campaign identification
SELECT
    campaign_id,
    company,
    campaign_type,
    channel_used,
    location,
    roi,
    ROUND(conversion_rate * 100, 2)                 AS conversion_rate_pct,
    cost_clean,
    engagement_score
FROM marketing_campaigns
WHERE roi <= PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY roi) OVER ()
  AND conversion_rate <= PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY conversion_rate) OVER ()
ORDER BY roi ASC
LIMIT 25;


-- ============================================================
-- SECTION 9: BUDGET OPTIMIZATION ANALYSIS
-- ============================================================

-- 9.1 ROI per dollar spent by channel
SELECT
    channel_used,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(cost_clean), 0)                       AS avg_cost,
    ROUND(AVG(roi) / NULLIF(AVG(cost_clean), 0) * 10000, 4) AS roi_per_dollar_spent,
    ROUND(SUM(cost_clean) / 1000000, 2)             AS total_spend_millions,
    COUNT(*)                                        AS campaigns
FROM marketing_campaigns
GROUP BY channel_used
ORDER BY roi_per_dollar_spent DESC;

-- 9.2 Budget allocation recommendation
-- Based on ROI performance, what % of budget each channel deserves
WITH channel_roi AS (
    SELECT
        channel_used,
        AVG(roi) AS avg_roi
    FROM marketing_campaigns
    GROUP BY channel_used
)
SELECT
    channel_used,
    ROUND(avg_roi, 3)                               AS avg_roi,
    ROUND(avg_roi / SUM(avg_roi) OVER() * 100, 1)  AS recommended_budget_pct,
    ROUND(avg_roi / SUM(avg_roi) OVER() * 2500, 0) AS recommended_spend_millions
FROM channel_roi
ORDER BY recommended_budget_pct DESC;


-- ============================================================
-- SECTION 10: TABLEAU EXPORT VIEWS
-- ============================================================

-- Master flat view for Tableau
CREATE OR REPLACE VIEW vw_campaign_master AS
SELECT
    campaign_id,
    company,
    campaign_type,
    target_audience,
    duration,
    channel_used,
    ROUND(conversion_rate * 100, 2)                 AS conversion_rate_pct,
    cost_clean                                      AS acquisition_cost,
    roi,
    location,
    language,
    clicks,
    impressions,
    ROUND(ctr * 100, 4)                             AS ctr_pct,
    ROUND(cpc, 2)                                   AS cost_per_click,
    ROUND(cpm, 2)                                   AS cost_per_thousand,
    engagement_score,
    customer_segment,
    date,
    month_num,
    quarter,
    CASE
        WHEN roi >= 6.0 THEN 'Top Performer'
        WHEN roi >= 5.0 THEN 'Strong Performer'
        WHEN roi >= 4.0 THEN 'Mid Performer'
        ELSE 'Low Performer'
    END AS performance_tier
FROM marketing_campaigns;

-- Channel summary for Tableau charts
CREATE OR REPLACE VIEW vw_channel_summary AS
SELECT
    channel_used,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(cost_clean), 0)                       AS avg_acquisition_cost,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement_score,
    SUM(clicks)                                     AS total_clicks
FROM marketing_campaigns
GROUP BY channel_used
ORDER BY avg_roi DESC;

-- Monthly summary for trend charts
CREATE OR REPLACE VIEW vw_monthly_summary AS
SELECT
    month_num,
    quarter,
    COUNT(*)                                        AS campaigns,
    ROUND(AVG(roi), 3)                              AS avg_roi,
    ROUND(AVG(conversion_rate) * 100, 2)            AS avg_conversion_rate_pct,
    ROUND(AVG(ctr) * 100, 2)                        AS avg_ctr_pct,
    SUM(clicks)                                     AS total_clicks,
    ROUND(AVG(cost_clean), 0)                       AS avg_cost,
    ROUND(AVG(engagement_score), 2)                 AS avg_engagement
FROM marketing_campaigns
GROUP BY month_num, quarter
ORDER BY month_num;

SELECT * FROM vw_campaign_master LIMIT 10;
