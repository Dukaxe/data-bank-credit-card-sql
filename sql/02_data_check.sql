/* =========================================================
   02. Kiểm tra dữ liệu trước khi phân tích
   Format - Outlier - NULL - quan hệ giữa các bảng
   ========================================================= */
USE data_bank;
GO

-- Số dòng mỗi bảng
SELECT 'customer_info' AS tbl, COUNT(0) AS n FROM customer_info
UNION ALL SELECT 'customer_region', COUNT(0) FROM customer_region
UNION ALL SELECT 'customer_transactions', COUNT(0) FROM customer_transactions
UNION ALL SELECT 'regions', COUNT(0) FROM regions;
-- 700 / 828 / 5868 / 5

-- Khoảng thời gian giao dịch
SELECT MIN(txn_date) AS first_day, MAX(txn_date) AS last_day
FROM customer_transactions;
-- 2020-01-01 -> 2020-04-28 (tháng 4 chưa đủ tháng)

-- Giá trị phân loại
SELECT Education, COUNT(0) AS n FROM customer_info GROUP BY Education;
-- '2n Cycle' = Master (1st cycle = Bachelor, 2nd cycle = Master, 3rd cycle = PhD)

SELECT Marital_Status, COUNT(0) AS n FROM customer_info GROUP BY Marital_Status;
-- 'Alone' (3 KH) cùng nghĩa với 'Single'

SELECT txn_type, COUNT(0) AS n, MIN(txn_amount) AS min_amt, MAX(txn_amount) AS max_amt
FROM customer_transactions
GROUP BY txn_type;

-- Outlier: năm sinh và thu nhập
SELECT MIN(Year_Birth) AS min_year, MAX(Year_Birth) AS max_year,
       MIN(Income) AS min_income, MAX(Income) AS max_income
FROM customer_info;
-- có KH sinh năm 1893, 1899, 1900

SELECT COUNT(0) AS income_zero
FROM customer_info
WHERE Income = 0;
-- 13 KH thu nhập = 0 -> coi là thiếu dữ liệu, không phải thu nhập thật

-- Chính sách: chỉ mở thẻ cho KH dưới 70 tuổi
SELECT ID, Year_Birth, Dt_Customer, YEAR(Dt_Customer) - Year_Birth AS age_at_open
FROM customer_info
WHERE YEAR(Dt_Customer) - Year_Birth > 70;
-- 5 KH vi phạm (gồm 3 KH năm sinh sai)

-- KH không xác định được châu lục
SELECT region_id, COUNT(0) AS n
FROM customer_region
WHERE region_id NOT IN (SELECT region_id FROM regions)
GROUP BY region_id;
-- region_id = 6: 10 KH

-- KH có thông tin nhưng không có giao dịch
SELECT COUNT(0) AS no_txn
FROM customer_info
WHERE ID NOT IN (SELECT DISTINCT customer_id FROM customer_transactions);
-- 200 KH (ID 501 trở đi) không có giao dịch trong kỳ

-- Hồ sơ trùng: khác ID nhưng giống hệt năm sinh, học vấn, hôn nhân, thu nhập, ngày mở thẻ
SELECT Year_Birth, Education, Marital_Status, Income, Dt_Customer, COUNT(0) AS n
FROM customer_info
GROUP BY Year_Birth, Education, Marital_Status, Income, Dt_Customer
HAVING COUNT(0) > 1;
-- 20 nhóm; giao dịch của các hồ sơ này khác nhau -> giữ lại, ghi chú để hỏi bộ phận dữ liệu
