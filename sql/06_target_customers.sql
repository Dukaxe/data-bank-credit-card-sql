/* =========================================================
   06. Chọn danh sách KH mời mở thẻ tín dụng
   4 điều kiện, xét trên TỪNG KHÁCH HÀNG (không dùng trung bình nhóm):
     (1) Có nhu cầu      : net_flow < 0
     (2) Thu nhập đủ     : thu nhập >= 4,000 USD/tháng
     (3) Trả được        : phần thâm hụt <= 1 tháng thu nhập
     (4) Còn bán chéo    : dưới 60 tuổi (vay mua xe, mua nhà sau này)
   ========================================================= */
USE data_bank;
GO

DROP TABLE IF EXISTS target_customers;

SELECT
      ID
    , region_name
    , age
    , age_group
    , education
    , marital_status
    , children
    , monthly_income
    , net_flow
    , -net_flow / monthly_income AS deficit_to_income
INTO target_customers
FROM customer_base
WHERE net_flow < 0
  AND monthly_income >= 4000
  AND -net_flow <= monthly_income
  AND age < 60;

-- Phễu: mỗi điều kiện loại bao nhiêu KH
SELECT
      COUNT(0) AS all_customers
    , SUM(CASE WHEN net_flow < 0 THEN 1 ELSE 0 END) AS step1_need
    , SUM(CASE WHEN net_flow < 0 AND monthly_income >= 4000 THEN 1 ELSE 0 END) AS step2_income
    , SUM(CASE WHEN net_flow < 0 AND monthly_income >= 4000
                AND -net_flow <= monthly_income THEN 1 ELSE 0 END) AS step3_capacity
    , SUM(CASE WHEN net_flow < 0 AND monthly_income >= 4000
                AND -net_flow <= monthly_income AND age < 60 THEN 1 ELSE 0 END) AS step4_age
FROM customer_base;
-- 495 -> 283 -> 147 -> 102 -> 69

-- KH mục tiêu nằm ở đâu
SELECT
      T1.region_name
    , COUNT(T2.ID) AS targets
    , COUNT(0) AS customers
    , COUNT(T2.ID) * 100.0 / COUNT(0) AS pct_target
FROM customer_base T1
LEFT JOIN target_customers T2 ON T1.ID = T2.ID
GROUP BY T1.region_name
ORDER BY pct_target DESC;

-- Quy mô: tổng phần chi tiêu thiếu hụt mỗi tháng của nhóm mục tiêu
SELECT
      COUNT(0) AS targets
    , AVG(monthly_income) AS avg_monthly_income
    , AVG(-net_flow) AS avg_monthly_gap
    , SUM(-net_flow) AS total_monthly_gap
FROM target_customers;

-- Xuất danh sách cho bộ phận bán hàng
SELECT * FROM target_customers ORDER BY deficit_to_income DESC;
