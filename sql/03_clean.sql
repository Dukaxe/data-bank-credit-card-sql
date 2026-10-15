/* =========================================================
   03. Làm sạch dữ liệu -> customer_clean, transactions_clean
   ========================================================= */
USE data_bank;
GO

-- B1: Bảng khách hàng sạch
DROP TABLE IF EXISTS customer_clean;

SELECT
      T1.ID
    , T1.Year_Birth
    , 2020 - T1.Year_Birth AS age
    , CASE WHEN T1.Education = '2n Cycle' THEN 'Master' ELSE T1.Education END AS education
    , CASE WHEN T1.Marital_Status = 'Alone' THEN 'Single' ELSE T1.Marital_Status END AS marital_status
    , NULLIF(T1.Income, 0) AS income                 -- 0 = thiếu dữ liệu -> NULL để AVG bỏ qua
    , T1.Kidhome + T1.Teenhome AS children
    , T1.Dt_Customer
    , T3.region_name
    , CASE
        WHEN 2020 - T1.Year_Birth < 30 THEN '20-30'
        WHEN 2020 - T1.Year_Birth < 40 THEN '30-40'
        WHEN 2020 - T1.Year_Birth < 50 THEN '40-50'
        WHEN 2020 - T1.Year_Birth < 60 THEN '50-60'
        WHEN 2020 - T1.Year_Birth < 70 THEN '60-70'
        ELSE '70+'
      END AS age_group
INTO customer_clean
FROM customer_info T1
JOIN customer_region T2 ON T1.ID = T2.customer_id
JOIN regions T3         ON T2.region_id = T3.region_id      -- bỏ region_id = 6
WHERE YEAR(T1.Dt_Customer) - T1.Year_Birth <= 70             -- chính sách dưới 70 tuổi
  AND T1.ID IN (SELECT DISTINCT customer_id FROM customer_transactions);

-- B2: Giao dịch của các KH trên
DROP TABLE IF EXISTS transactions_clean;

SELECT *
INTO transactions_clean
FROM customer_transactions
WHERE customer_id IN (SELECT ID FROM customer_clean);

SELECT COUNT(0) FROM customer_clean;      -- 495 KH
SELECT COUNT(0) FROM transactions_clean;  -- 5,798 giao dịch
