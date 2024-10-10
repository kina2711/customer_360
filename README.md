# Customer 360 Analysis: Overview and Key Tasks

This project focuses on customer segmentation and understanding customer purchasing behaviors using the RFM (Recency, Frequency, Monetary) model. The goal is to help a business analyze transaction data and segment customers to improve marketing strategies and customer engagement.
Tasks:

    Customer Insights:
        The company aims to understand customer purchasing trends.
        The analysis is focused on identifying key customer segments, their purchase frequency, and how recent and valuable their transactions are.

Insights:

    Customer Segmentation:
        Based on the RFM analysis, customers are segmented into groups such as Champions, Loyal Customers, At Risk, and Hibernating.
        Top Segments:
            Champions: Customers who purchase frequently and recently, contributing the highest revenue.
            Loyal Customers: Regular purchasers with a lower purchase amount but consistent interaction.
            At Risk: Previously frequent purchasers who have not returned recently—requiring targeted marketing to re-engage them.

    Key Findings:
        Hibernating Customers: This group represents a significant portion of the customer base, contributing large amounts of revenue but with lower frequency. They should be targeted for re-engagement campaigns.
        Champion Customers: Though a small segment, this group generates the highest revenue. Special attention should be given to maintaining their loyalty with personalized offers and experiences.
        At Risk Customers: These customers bring substantial revenue but are at risk of switching to competitors due to long gaps between purchases. Retention efforts should focus on this group to prevent loss.

Strategic Recommendations:

    Increase Engagement for Key Segments:
        Hibernating Customers: Offer personalized promotions or surveys to understand reasons for disengagement and encourage repeat purchases.
        Potential Loyalists: Focus on converting these customers into regular purchasers with loyalty programs and targeted incentives.

    Retention Strategies for Champions and Loyal Customers:
        Keep engaging Champion customers with exclusive offers and ensure a high-quality experience to maintain their high spending habits.
        Strengthen relationships with Loyal Customers by offering personalized rewards and maintaining consistent communication.

    Marketing Focus:
        The analysis highlights the need to direct marketing efforts toward At Risk and Hibernating customers while nurturing the high-value Champions segment.

SQL Code:

The project includes SQL scripts for calculating RFM scores and categorizing customers into segments based on their purchasing behavior. Here's a summary of the key SQL steps:

    Calculate Recency, Frequency, Monetary values for each customer.
    Assign RFM Scores using quartile-based scoring.
    Segment Customers based on their RFM scores and categorize them into groups like Champions, At Risk, and Loyal.
