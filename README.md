Digital Marketing Campaign Performance & KPI Analysis
SQL (PostgreSQL) · Campaign Analytics · Performance Marketing · Audience Segmentation

Overview
This project analyzes 200,000 digital marketing campaign records across 6 channels, 5 campaign types, 5 customer segments, and 5 US cities — covering the full calendar year 2021. The goal is to identify which channels, audiences, and campaign strategies deliver the strongest return on investment, and translate those findings into concrete budget allocation and targeting recommendations.
The analysis covers every KPI a performance analyst tracks in a real marketing environment — CTR, CPA, ROAS, CPM, CPC, conversion rate, engagement score, and ROI — broken down across every dimension in the dataset.

Dataset
Source: Marketing Campaign Performance Dataset (Kaggle)
Records: 200,000 campaigns
Period: January 2021 – December 2021
Columns: Campaign ID, Company, Campaign Type, Target Audience, Duration, Channel, Conversion Rate, Acquisition Cost, ROI, Location, Language, Clicks, Impressions, Engagement Score, Customer Segment, Date
Channels: Google Ads, Facebook, Instagram, YouTube, Email, Website
Campaign Types: Search, Display, Email, Social Media, Influencer
Customer Segments: Tech Enthusiasts, Fashionistas, Foodies, Health & Wellness, Outdoor Adventurers
Locations: New York, Los Angeles, Chicago, Houston, Miami

Tools
PostgreSQL for all KPI calculation, segmentation, trend analysis, and budget optimization modeling. Tableau Public for interactive dashboard development.

KPIs Calculated
Every metric was calculated directly from raw data in SQL — no pre-computed fields used.
KPIFormulaBusiness UseCTRClicks ÷ ImpressionsAd creative effectivenessConversion RateConversions ÷ ClicksLanding page and offer qualityCPCSpend ÷ ClicksCost efficiency per visitorCPMSpend ÷ Impressions × 1,000Reach cost efficiencyROIRevenue ÷ SpendOverall campaign returnEngagement ScorePlatform-providedAudience resonanceEst. Cost per ConversionSpend ÷ (Conv Rate × Clicks)True acquisition costROI per Dollar SpentROI ÷ Spend × 10,000Budget efficiency index

Analysis Structure
The SQL script runs across 10 sections covering the full performance analytics workflow.
Section 1 handles data cleaning — converting the acquisition cost field from string to numeric and calculating all derived KPI columns. Section 2 establishes the executive KPI summary — the numbers a CMO sees first. Section 3 breaks down performance by channel across all 8 KPIs. Section 4 analyzes campaign type effectiveness and duration impact. Section 5 performs audience segmentation — identifying which customer segments and demographic groups convert best. Section 6 covers geographic analysis across all 5 locations. Section 7 runs monthly and quarterly trend analysis with MoM ROI calculations using LAG(). Section 8 scores campaigns into performance tiers and surfaces the top and bottom performers. Section 9 runs budget optimization analysis — calculating recommended spend allocation by channel based on ROI weighting. Section 10 creates clean Tableau-ready views.

Key Findings
Facebook leads all channels on ROI at 5.019x, followed closely by Website at 5.014x — both outperforming the portfolio average of 5.00x. Instagram trails at 4.989x, suggesting its higher CPM is not being offset by stronger conversion performance.
YouTube drives the highest average CTR at 14.12%, making it the most effective channel for generating clicks relative to impressions. However, its ROI of 4.994x sits below the portfolio average, pointing to a click quality issue — users are clicking but not converting at the same rate as other channels.
Influencer campaigns deliver the strongest ROI at 5.011x and the highest average conversion rate at 8.03%, outperforming Search, Display, Email, and Social Media. The data suggests influencer spend is generating the most efficient return in this portfolio.
Men 25–34 is the highest-ROI audience segment at 5.021x, followed by Women 35–44 at 5.006x. Men 18–24, despite having the highest campaign volume, delivers the lowest ROI at 4.983x — indicating potential over-investment in this demographic relative to its return.
Miami generates the highest average ROI at 5.012x, while New York — the largest market — underperforms at 4.980x. This geographic gap suggests budget reallocation away from New York toward Miami and Los Angeles could improve overall portfolio efficiency.
September is the peak performance month with an average ROI of 5.029x, while July is the weakest at 4.983x. Q3 budget pacing should be reviewed to ensure spend is concentrated in September rather than distributed evenly across the quarter.
The Foodies segment leads on ROI at 5.004x with the highest conversion rate at 8.03% — making it the most efficient audience to acquire. Outdoor Adventurers is the lowest performer at 4.999x ROI, suggesting creative or channel misalignment for this segment.

Strategic Recommendations
Reallocate budget toward Facebook and Website channels. Both consistently outperform the portfolio ROI average. A 5% budget shift from Instagram to Facebook across equivalent campaign types is projected to improve blended portfolio ROI.
Investigate the YouTube click-quality gap. YouTube's CTR of 14.12% is the highest in the portfolio, but its ROI trails Facebook and Website. The likely cause is audience or landing page misalignment — users are clicking but not converting. A/B testing landing pages specifically for YouTube traffic is the recommended next step.
Scale Influencer campaign spend. With the highest ROI and conversion rate across all campaign types, influencer campaigns are underutilized relative to their performance. A controlled budget increase of 10–15% toward influencer programs is warranted.
Reduce over-investment in Men 18–24. This is the highest-volume demographic but the lowest-ROI audience. Shifting budget toward Men 25–34 and Women 35–44 would improve blended conversion efficiency without sacrificing reach.
Concentrate Q3 spend in September. With September delivering the peak ROI of the year, even distribution of Q3 budget across July, August, and September leaves return on the table. Front-loading September spend in high-performing channels captures this seasonal peak more effectively.
Develop city-specific channel strategies. Miami's outperformance suggests market-level differences in audience behavior. Analyzing channel-location combinations reveals that the same channel can deliver meaningfully different results in different cities — standardizing channel mix across all markets leaves geographic alpha uncaptured.
