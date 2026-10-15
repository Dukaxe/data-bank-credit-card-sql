/* =========================================================
   05. Phân tích theo 5 chiều
   Châu lục - Độ tuổi - Học vấn - Hôn nhân - Số con
   Mỗi nhóm: số KH, thu nhập TB/tháng, dòng tiền ròng TB, % KH thâm hụt
   ========================================================= */
USE data_bank;
GO

DROP TABLE IF EXISTS segment_summary;

SELECT 'Region' AS dimension, region_name AS segment
     , COUNT(0) AS customers
     , AVG(monthly_income) AS avg_monthly_income
     , AVG(net_flow) AS avg_net_flow
     , AVG(is_deficit * 100.0) AS pct_deficit
INTO segment_summary
FROM customer_base GROUP BY region_name

UNION ALL
SELECT 'Age', age_group, COUNT(0), AVG(monthly_income), AVG(net_flow), AVG(is_deficit * 100.0)
FROM customer_base GROUP BY age_group

UNION ALL
SELECT 'Education', education, COUNT(0), AVG(monthly_income), AVG(net_flow), AVG(is_deficit * 100.0)
FROM customer_base GROUP BY education

UNION ALL
SELECT 'Marital', marital_status, COUNT(0), AVG(monthly_income), AVG(net_flow), AVG(is_deficit * 100.0)
FROM customer_base GROUP BY marital_status

UNION ALL
SELECT 'Children', CAST(children AS VARCHAR(2)), COUNT(0), AVG(monthly_income), AVG(net_flow), AVG(is_deficit * 100.0)
FROM customer_base GROUP BY children;

SELECT * FROM segment_summary ORDER BY dimension, segment;


-- Kết hợp 3 chiều ổn định, dễ thu thập: châu lục x nhóm tuổi x có con
SELECT
      region_name
    , age_group
    , CASE WHEN children > 0 THEN 'Có con' ELSE 'Không con' END AS has_children
    , COUNT(0) AS customers
    , AVG(monthly_income) AS avg_monthly_income
    , AVG(net_flow) AS avg_net_flow
    , AVG(is_deficit * 100.0) AS pct_deficit
FROM customer_base
GROUP BY region_name, age_group, CASE WHEN children > 0 THEN 'Có con' ELSE 'Không con' END
HAVING COUNT(0) >= 10          -- bỏ nhóm quá nhỏ
ORDER BY avg_net_flow;
