-- ============================================
-- RFM Customer Segmentation Analysis
-- Project: Superstore Sales Analysis
-- Author: Dharmesh Sapariya
-- ============================================

WITH max_date AS
(
SELECT
MAX(order_date) as max_order_date
FROM Sales
),
customer_rfm AS
(
SELECT 
s.Customer_Name,
m.max_order_date,
MAX(s.order_date) AS lastorderdate,
DATEDIFF(DAY,MAX(s.order_date),m.max_order_date) AS Recency_days,
COUNT(DISTINCT s.Order_ID) AS frequency,
SUM(s.profit) AS Monentery
FROM Sales s
CROSS JOIN max_date m
GROUP BY s.Customer_Name,m.max_order_date),
rfm_score AS
(
SELECT
Customer_Name,
Recency_days,
frequency,
Monentery,
NTILE(5) OVER(ORDER BY recency_days ASC) as R_score,
NTILE(5) OVER(ORDER BY frequency DESC) as F_score,
NTILE(5) OVER(ORDER BY Monentery DESC) as M_score
FROM customer_rfm
),
rfm_final AS
(
SELECT
*,
(R_score+F_score+M_score) AS RFM_total_score
FROM rfm_score)
SELECT
CASE WHEN RFM_total_score >=13 THEN 'Champions'
	 WHEN RFM_total_score >=10 THEN 'Loyal customer'
	 WHEN RFM_total_score >=7 THEN 'Potential customer'
	 WHEN RFM_total_score >=4 THEN 'At risk'
	 ELSE 'Lost customer'
	 END AS customer_segment,
COUNT(*) AS customer_count
FROM rfm_final
GROUP BY CASE WHEN RFM_total_score >=13 THEN 'Champions'
	 WHEN RFM_total_score >=10 THEN 'Loyal customer'
	 WHEN RFM_total_score >=7 THEN 'Potential customer'
	 WHEN RFM_total_score >=4 THEN 'At risk'
	 ELSE 'Lost customer'
	 END
ORDER BY customer_count DESC


