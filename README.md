# pl-sql-window-functions--Ines---Ingabire-Umurerwa-
Nesmu Freshpick Fruit is an innovative agricultural solution designed to address the challenge of fruit scarcity during summer months. Our project focuses on implementing greenhouse technology to protect fruit crops from excessive sun exposure and heat damage, ensuring year-round fruit production.
Problem Statement
During summer seasons, fruit production significantly decreases due to:

Excessive sun exposure causing heat stress to fruit plants
High temperatures damaging fruit quality and reducing yields
Limited availability of fresh fruits during peak summer months
Economic losses for farmers due to reduced harvest

Solution
Our solution involves the strategic implementation of greenhouse farming systems that:

Provide controlled environment for fruit cultivation
Protect crops from excessive sunlight and heat
Maintain optimal temperature and humidity levels
Enable year-round fruit production, especially during summer
Improve fruit quality and increase harvest yields

Key Features

Climate Control: Regulated temperature and humidity for optimal fruit growth
UV Protection: Specialized greenhouse materials to filter harmful sun rays
Water Efficiency: Integrated irrigation systems for optimal water usage
Extended Growing Season: Production of fruits during traditionally low-yield periods
Quality Assurance: Consistent fruit quality regardless of external weather conditions

Benefits
For Farmers

Increased crop yields during summer months
Reduced crop loss from heat damage
Stable income throughout the year
Protection from unpredictable weather conditions

For Consumers

Access to fresh fruits year-round
Better quality fruits
More stable pricing
Support for local agriculture

Environmental Impact

Efficient water usage through controlled irrigation
Reduced pesticide needs in controlled environment
Sustainable farming practices

Implementation Plan

Site Assessment: Evaluate land suitability and climate conditions
Greenhouse Design: Select appropriate greenhouse type and materials
Infrastructure Setup: Install greenhouse structures and climate control systems
Crop Planning: Determine fruit varieties suitable for greenhouse cultivation
Monitoring System: Implement sensors and monitoring for optimal conditions
Training: Educate farmers on greenhouse management techniques

Target Crops
Our greenhouse system is designed to cultivate various fruits including:

Strawberries
Tomatoes
Melons
Citrus fruits
Berries
And other heat-sensitive fruit varieties

Technology Stack

Climate control systems
Automated irrigation
Temperature and humidity sensors
Shade netting and UV-filtering materials
Ventilation systems

Future Goals

Expand greenhouse network to serve more farmers
Integrate smart farming technologies and IoT sensors
Develop partnerships with local markets and distributors
Create training programs for sustainable greenhouse farming
Research and implement renewable energy solutions for greenhouses

Contact
For more information about Nesmu Freshpick Fruit project:

Business Name: Nesmu Freshpick Fruit
Email: inesumurerwa100@gmail.com
Location: Musanze-Rwanda

Contributing
We welcome collaboration from agricultural experts, investors, and technology partners interested in sustainable fruit 
production solutions.
Dataschema Users/user/Downloads/database%20schema.pdf
Relationships
<img width="4169" height="5906" alt="Edraw" src="https://github.com/user-attachments/assets/c6eec33a-2bad-47f1-9e11-f20781a95830" />


function queries
1. ranking functions
   SELECT *
FROM (
    SELECT 
        region,
        name AS product_name,
        total_sales,
        total_quantity,

        -- gives unique numbers which are sequential for each region
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_sales DESC) AS row_number_rank,

        -- show ranking with gaps for ties
        RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS sales_rank,

        -- show ranking without gaps for ties
        DENSE_RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS dense_sales_rank,

        -- shows relative rank as percentage within each region
        PERCENT_RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS percent_rank

    FROM (
        SELECT 
            c.region,
            p.name,
            SUM(t.amount) AS total_sales,
            SUM(t.quantity) AS total_quantity
        FROM transactions t
        JOIN products p ON t.product_id = p.product_id
        JOIN customers c ON t.customer_id = c.customer_id
        WHERE t.sale_date >= DATE '2025-01-20'
        GROUP BY c.region, p.name
    ) product_region_sales
) ranked_sales
WHERE sales_rank <= 5
ORDER BY region, sales_rank;

-- INTERPRETATION
-- This query shows the performance of sales for different regions 
-- to help the department identify products that perform highly.

  2. aggregate Function
     SELECT
    sale_year,
    sale_month,
    monthly_sales,
    -- Running total for the year (cumulative)
    SUM(monthly_sales) OVER (
        PARTITION BY sale_year
        ORDER BY sale_month
        ROWS UNBOUNDED PRECEDING
    ) as running_total_ytd,
    -- 3-month moving average using ROWS frame
    AVG(monthly_sales) OVER (
        ORDER BY sale_year, sale_month
        ROWS 2 PRECEDING
    ) as moving_avg_3month_rows,
    -- Maximum sales in 3-month window
    MAX(monthly_sales) OVER (
        ORDER BY sale_year, sale_month
        ROWS 2 PRECEDING
    ) as max_3month_window,
    -- Minimum sales in 3-month window
    MIN(monthly_sales) OVER (
        ORDER BY sale_year, sale_month
        ROWS 2 PRECEDING
    ) as min_3month_window
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date) as sale_year,
        EXTRACT(MONTH FROM sale_date) as sale_month,
        SUM(amount) as monthly_sales
    FROM transactions
    WHERE sale_date >= DATE '2025-01-15'  -- Use historical date for actual data
    GROUP BY EXTRACT(YEAR FROM sale_date), EXTRACT(MONTH FROM sale_date)
) monthly_summary
ORDER BY sale_year, sale_month;
INTERPRETATION:
This query shows monthly sales trends using various window functions that provide 
multiple perspectives on sales performance over time.
3.navigation function
SELECT
region,
sale_month,
monthly_sales,
-- sales of month  using LAG() showing previous month
LAG(monthly_sales, 1) OVER (
PARTITION BY region
ORDER BY sale_month
) as prev_month_sales,
-- forecasting Next month sales using LEAD()
LEAD(monthly_sales, 1) OVER (
PARTITION BY region
ORDER BY sale_month
) as next_month_sales,
--growth percentage of every month
ROUND(
((monthly_sales - LAG(monthly_sales, 1) OVER (
PARTITION BY region
ORDER BY sale_month
)) * 100.0) /
NULLIF(LAG(monthly_sales, 1) OVER (
PARTITION BY region
ORDER BY sale_month
), 0), 2
) as mom_growth_percent,
-- ir indicates intended growth
CASE
WHEN monthly_sales > LAG(monthly_sales, 1) OVER (
PARTITION BY region ORDER BY sale_month
) THEN 'Growing'
WHEN monthly_sales < LAG(monthly_sales, 1) OVER (
PARTITION BY region ORDER BY sale_month
) THEN 'Declining'
ELSE 'Stable'
END as growth_trend
FROM (
SELECT
c.region,
EXTRACT(MONTH FROM sale_date) as sale_month,
SUM(amount) as monthly_sales
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
WHERE t.sale_date >= DATE '2025-05-15'
GROUP BY c.region, EXTRACT(MONTH FROM sale_date)
) region_monthly_sales
ORDER BY region, sale_month;
--INTERPRATATION
--This query shows the performance of months analysing historical data to predict the performance for the future
4.Distribution Function
SELECT
 name as customer_name,
 region,
 total_spent,
 transaction_count,
 avg_transaction_value,
 -- This segments customers into 4 quartiles (segments)
 NTILE(4) OVER (ORDER BY total_spent DESC) as customer_quartile,
 -- Percentage of Cumulative distribution
 ROUND(CUME_DIST() OVER (ORDER BY total_spent DESC) * 100, 2) as cumulative_percentile,
 CASE
   WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 1 THEN 'VIP Customers (Top 25%)'
   WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 2 THEN 'High Value (26-50%)'
   WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 3 THEN 'Medium Value (51-75%)'
   ELSE 'Basic Customers (Bottom 25%)'
 END as customer_segment,
 CASE
   WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 1 THEN 'Premium offers, exclusive events'
   WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 2 THEN 'Loyalty rewards, bulk discounts'
   WHEN NTILE(4) OVER (ORDER BY total_spent DESC) = 3 THEN 'Regular promotions, seasonal offers'
   ELSE 'Basic promotions, retention campaigns'
 END as marketing_strategy
FROM (
 SELECT
   c.name,
   c.region,
   SUM(amount) as total_spent,  
   COUNT(t.transaction_id) as transaction_count,
   ROUND(AVG(amount), 2) as avg_transaction_value
 FROM customers c
 JOIN transactions t ON c.customer_id = t.customer_id
 WHERE t.sale_date >= DATE '2025-01-15'
 GROUP BY c.customer_id, c.name, c.region
 HAVING COUNT(t.transaction_id) >= 1-
) customer_summary
ORDER BY total_spent DESC;

-- INTERPRETATION
-- This query helps to do customer segmentation by dividing customers into 4 value-based tiers
-- based on their total spending, and provides targeted marketing strategies for each segment
Nesmu Freshpick Fruit - Results Analysis
Step 6: Results Analysis

1. DESCRIPTIVE ANALYSIS 
Summary Overview
Nesmu Freshpick Fruit operates three greenhouses (1,550 sqm total) successfully producing summer fruits in controlled environments. Climate data shows stable temperatures (21.8°C - 24.8°C) and humidity (58% - 67%) within optimal ranges. Currently cultivating 2,900 plants across four fruit varieties with 100% survival rate and all crops in healthy "Growing" status.
Key Patterns
Production Success:

Summer fruit cultivation achieved during traditionally difficult months (June-August)
Zero crop failures across all 2,900 plants (1,000 strawberries, 800 tomatoes, 500 melons, 600 peppers)
Climate control maintaining optimal conditions despite external summer heat

Market Position:

Four customer segments established: Wholesale, Retail, Restaurant, and Supermarket
Both B2B and B2C channels activated for diverse revenue streams

2. DIAGNOSTIC ANALYSIS 
Root Causes of Success
Climate Control Effectiveness:

Temperature-controlled greenhouses prevented the primary problem: excessive sun exposure causing fruit damage
Humidity regulation systems prevented dehydration and heat stress in plants
Protective infrastructure filtered harmful UV rays while maintaining necessary light for photosynthesis

Strategic Planning:

Planting dates (May-June) strategically timed to produce harvests during traditional low-supply summer months
Diverse fruit selection (strawberries, melons, tomatoes, peppers) spreads risk and meets varied market demands
Staggered planting dates ensure continuous production flow

Infrastructure Investment:

Installation of automated irrigation systems reduced water waste and ensured consistent moisture
Modern greenhouse materials with temperature control addressed the core business problem
Adequate facility size (450-600 sqm per unit) allows commercial-scale production

Comparative Factors
Greenhouse Performance Comparison:

Greenhouse C (600 sqm, installed earliest) positioned for year-round operation vs. summer-specific units
Greenhouse B maintains coolest temperatures, possibly due to superior ventilation or location
Size variations (450-600 sqm) reflect different capacity strategies

Crop Selection Rationale:

Strawberries (60-day harvest) chosen for fastest turnaround and high summer demand
Tomatoes (75-day harvest) provide reliable year-round production
Melons (90-day harvest) align with peak summer consumption periods despite longer growing time

Influencing Factors
External Market Forces:

Summer fruit scarcity creates high demand and premium pricing opportunities
Multiple customer segments indicate strong market interest across retail channels
Traditional outdoor farming's summer limitations create competitive advantage for greenhouse production

Operational Factors:

Active maintenance scheduling preserves greenhouse functionality
Real-time climate monitoring (multiple daily readings) enables rapid response to environmental changes
Quality grading system (Premium to Grade C) ensures market-appropriate pricing

Geographic/Environmental Context:

External summer conditions (high sun exposure, heat) necessitate controlled environment agriculture
Local market access through diverse customer base (4+ established relationships)

3. PRESCRIPTIVE ANALYSIS – What Should Happen Next?
Immediate Recommendations (0-3 months)
Optimize Climate Control:

Install additional ventilation in Greenhouse A to reduce afternoon temperature spikes (2.3°C increase observed)
Implement automated shade systems that adjust based on time of day and external temperature
Set temperature alert systems at 26°C threshold to prevent heat stress

Harvest Preparation:

Prepare harvest equipment and storage facilities for upcoming strawberry harvest (expected July 30)
Establish quality control protocols to maximize Premium and Grade A classification
Pre-negotiate pricing with wholesale customers for guaranteed bulk purchases

Data Collection Enhancement:

Increase climate monitoring to 4-6 readings per day (currently 2) for better pattern analysis
Begin tracking individual plant health metrics, not just environmental conditions
Document actual vs. expected harvest dates to refine future planting schedules

Short-term Actions (3-6 months)
Expand Production Capacity:

Add 1-2 additional summer-focused greenhouse units (500 sqm each) to meet market demand
Prioritize high-value, fast-turnover crops (strawberries, bell peppers) for new facilities
Calculate ROI: If current 1,550 sqm produces X kg, 1,000 sqm expansion = 65% capacity increase

Market Development:

Formalize contracts with existing customers to guarantee purchase volumes
Target 3-5 additional restaurant clients for premium produce at higher margins
Develop direct-to-consumer sales channel (farmers market, online orders) for premium pricing

Revenue Optimization:

Implement dynamic pricing based on quality grades (Premium = 30% markup, Grade A = 15% markup)
Bundle slower-moving produce with high-demand items for wholesale customers
Create "summer harvest boxes" for direct retail sales

Long-term Strategic Initiatives (6-12 months)
Technology Integration:

Install IoT sensor networks for automated climate control (reduce labor, improve precision)
Implement predictive analytics to forecast optimal harvest windows based on historical data
Develop mobile app for real-time greenhouse monitoring and alerts

Sustainability & Efficiency:

Install solar panels on greenhouse roofs to offset climate control energy costs
Implement rainwater harvesting systems to reduce irrigation water costs by 40-60%
Explore organic certification to access premium market segments

Business Model Evolution:

Develop "Greenhouse-as-a-Service" model to help local farmers adopt technology
Create training programs for sustainable summer fruit production
Establish cooperative relationships with nearby farmers to expand regional production capacity

Risk Mitigation Strategies
Operational Risks:

Maintain backup climate control systems to prevent crop loss from equipment failure
Diversify crop portfolio (currently 5 types) to spread risk across different harvest cycles
Build 2-week buffer inventory to handle unexpected harvest delays

Market Risks:
Secure 60% of production through pre-season contracts before planting
Develop value-added products (jams, dried fruits) to absorb excess production
Create tiered pricing structure flexible enough to respond to market fluctuations
Financial Risks:
Set aside 15% of revenue for emergency maintenance fund
Obtain crop insurance for high-value summer harvests
Maintain cash reserves equal to 3 months operating expenses
Success Criteria for Next 12 Months
Production Goal: Successfully harvest and sell 100% of currently planted crops with 70%+ Premium/Grade A quality
Revenue Goal: Generate profitable returns demonstrating greenhouse ROI within 2-3 growing seasons
Market Goal: Establish 8-10 reliable customer relationships across all segments
Operational Goal: Achieve 95%+ uptime on all greenhouse climate control systems
Expansion Goal: Add 1,000+ sqm of new greenhouse capacity by end of year
References
1.Jensen, M. H., & Malter, A. J. (1995). Protected agriculture: A global review. World Bank Technical Paper No. 253. Washington, DC: World Bank Publications.
2.Castilla, N., & Hernandez, J. (2007). Greenhouse technological packages for high-quality crop production. Acta Horticulturae, 761, 285-297.
3.Gruda, N., Bisbis, M., & Tanny, J. (2019). Impacts of protected cultivation on climate change mitigation and adaptation strategies. Journal of Cleaner Production, 225, 155-169.
4.Shamshiri, R. R., et al. (2018). Advances in greenhouse automation and controlled environment agriculture: A transition to plant factories and urban agriculture. International Journal of Agricultural and Biological Engineering, 11(1), 1-22.
5.Zhang, Y., Gauthier, L., de Halleux, D., Dansereau, B., & Gosselin, A. (1996). Effect of covering materials on energy consumption and greenhouse microclimate. Agricultural and Forest Meteorology, 82(1-4), 227-244.
6.Food and Agriculture Organization (FAO). (2017). Good agricultural practices for greenhouse vegetable production in the South East European countries. FAO Plant Production and Protection Paper 230. Rome: FAO. Available at: https://www.fao.org/publications
7.MySQL Documentation. (2024). MySQL 8.0 Reference Manual. Oracle Corporation. Available at: https://dev.mysql.com/doc/
8.GitHub Guides. (2024). Mastering Markdown. GitHub, Inc. Available at: https://guides.github.com/features/mastering-markdown
9.World Bank Group. (2020). Climate-Smart Agriculture: Building Resilience to Climate Change. Washington, DC: World Bank Publications. Available at: https://www.worldbank.org/en/topic/climate-smart-agriculture
10.Resh, H. M. (2012). Hydroponic food production: A definitive guidebook for advanced home gardener and commercial hydroponic grower (7th ed.). Boca Raton, FL: CRC Press.
Integrity statement
I hereby declare that this assignment shows  my original work and no AI tools were used to generate content. All references were properly cited and contains the content that is related.


