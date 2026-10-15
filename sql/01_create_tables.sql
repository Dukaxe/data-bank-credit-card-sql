/* =========================================================
   01. Tạo database và các bảng
   SQL Server (T-SQL). Chạy 1 lần.
   ========================================================= */

CREATE DATABASE data_bank;
GO
USE data_bank;
GO

CREATE TABLE regions (
    region_id   INT,
    region_name VARCHAR(20)
);

CREATE TABLE customer_region (
    customer_id INT,
    region_id   INT
);

CREATE TABLE customer_info (
    ID             INT,
    Year_Birth     INT,
    Education      VARCHAR(20),
    Marital_Status VARCHAR(20),
    Income         INT,          -- thu nhập năm (USD)
    Kidhome        INT,
    Teenhome       INT,
    Dt_Customer    DATE          -- ngày mở thẻ
);

CREATE TABLE customer_transactions (
    customer_id INT,
    txn_date    DATE,
    txn_type    VARCHAR(20),     -- deposit / withdrawal / purchase
    txn_amount  INT
);
GO

-- Nạp dữ liệu từ file CSV (đổi lại đường dẫn cho đúng máy).
-- Cách khác: chuột phải database > Tasks > Import Flat File.
SET DATEFORMAT mdy;   -- ngày trong file CSV dạng m/d/yyyy

BULK INSERT regions               FROM 'C:\data_bank\regions.csv'               WITH (FORMAT = 'CSV', FIRSTROW = 2);
BULK INSERT customer_region       FROM 'C:\data_bank\customer_region.csv'       WITH (FORMAT = 'CSV', FIRSTROW = 2);
BULK INSERT customer_info         FROM 'C:\data_bank\customer_info.csv'         WITH (FORMAT = 'CSV', FIRSTROW = 2);
BULK INSERT customer_transactions FROM 'C:\data_bank\customer_transactions.csv' WITH (FORMAT = 'CSV', FIRSTROW = 2);
GO
